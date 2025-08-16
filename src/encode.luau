local instance = require("./instance")
local referent = require("./referent")
local dom = require("./dom")
local compress = require("./compress")
local database = require("./database")
local constants = require("./constants")
local writer = require("./writer")
local RobloxType = require("./roblox-type")

local MAGIC_NUMBER = constants.MAGIC_NUMBER
local MAGIC_NUMBER_LEN = #MAGIC_NUMBER

local SUPPORTED_VERSION = constants.SUPPORTED_VERSION
local SSTR_VERSION = constants.SSTR_VERSION
local PRNT_VERSION = constants.PRNT_VERSION

local END_CONTENT = constants.END_CONTENT
local END_CONTENT_LEN = #END_CONTENT

type CollectedClass = {
	ClassName: string,
	TypeId: number,
	Referents: { referent.Referent },
}

local function dump_hex(blob: buffer, starting_at: number?)
	local tab: { string } = {}
	for i = starting_at or 0, buffer.len(blob) - 1 do
		table.insert(tab, string.format("%02x", buffer.readu8(blob, i)))
	end
	print(table.concat(tab, " "))
end

local function is_service_class(class_name: string): boolean
	return false
end

local function referent_sort(a: referent.Referent, b: referent.Referent): boolean
	return a.id < b.id
end

local function inst_sort(a: CollectedClass, b: CollectedClass): boolean
	return a.ClassName < b.ClassName
end

local referent_cache = {}
local last_referent = 1
local function referent_map(referent: referent.Referent): number
	local mapped_value = referent_cache[referent.id]
	if not mapped_value then
		mapped_value = last_referent
		referent_cache[referent.id] = last_referent
		last_referent += 1
	end
	return mapped_value
end

local function encode_META(metadata: { [string]: string }): buffer
	local count = 0
	local len = 4
	for k, v in metadata do
		len += 8 + #k + #v
		count += 1
	end

	local blob = buffer.create(len)
	local cursor = 4
	buffer.writeu32(blob, 0, count)
	for k, v in metadata do
		cursor = writer.string(blob, cursor, k)
		cursor = writer.string(blob, cursor, v)
	end

	return blob
end

local function encode_INSTs(collected_classes: { CollectedClass }): { buffer }
	-- TODO: Check if an INST is a service
	local chunks = table.create(#collected_classes) :: { buffer }
	for type_id, data in collected_classes do
		data.TypeId = type_id - 1
		local is_service = is_service_class(data.ClassName)

		-- 4 for type_id, 4 for ClassName length, 1 for object format
		-- 4 for instance count = 13
		local blob_length = 13 + #data.ClassName + 4 * #data.Referents
		if is_service then
			blob_length += #data.Referents
		end
		local blob = buffer.create(blob_length)
		buffer.writeu32(blob, 0, data.TypeId)
		local cursor = writer.string(blob, 4, data.ClassName)
		buffer.writeu8(blob, cursor, if is_service then 0x01 else 0x00)
		buffer.writeu32(blob, cursor + 1, #data.Referents)

		local referents = table.create(#data.Referents, 0)
		for i, v in data.Referents do
			referents[i] = referent_map(v)
		end
		cursor = writer.referent_array(blob, cursor + 5, referents)

		if is_service then
			buffer.fill(blob, cursor, 1)
		end

		chunks[type_id] = blob
	end

	return chunks
end

local function encode_PROPs(dom: dom.DOM, collected_classes: { CollectedClass }): ({ buffer }, { string })
	local sstr_list: { string } = {}
	local sstr_map: { [string]: number } = {}
	local chunks = {}

	local prop_map: { [string]: RobloxType.RobloxType } = {}
	local prop_list: { string } = {}
	local instances: { instance.Instance } = {}
	for _, class in collected_classes do
		for _, referent in class.Referents do
			local inst = dom.instances[referent]
			for prop_name, prop_value in inst.Properties do
				if not prop_map[prop_name] then
					prop_map[prop_name] = prop_value.ty
					-- The only reason we do this is so we can sort the
					-- properties. Determinism has a cost.
					table.insert(prop_list, prop_name)
				end
			end
			table.insert(instances, inst)
		end
		table.sort(prop_list)

		for _, prop_name in prop_list do
			local values: { unknown } = {}
			local ty = prop_map[prop_name]
			for _, inst in instances do
				local prop_value = inst.Properties[prop_name]
				if not prop_value then
					prop_value = database.default_value(ty)
				end
				if prop_value.ty ~= ty then
					-- TODO: Support data type migrations
					error(
						`cannot write binary file: property {class.ClassName}.{prop_name} is the wrong type (expected {ty} but it was of type {prop_value.ty})`,
						2
					)
				end
				table.insert(values, prop_value.value)
			end

			local properties_size = RobloxType.size[ty](values)
			local blob = buffer.create(properties_size + 9 + #prop_name)
			buffer.writeu32(blob, 0, class.TypeId)
			local cursor = writer.string(blob, 4, prop_name)
			buffer.writeu8(blob, cursor, RobloxType.ids.from_type[ty])
			cursor += 1

			if ty == "String" then
				for _, value in values :: { string } do
					cursor = writer.string(blob, cursor, value)
				end
			elseif ty == "Bool" then
				cursor -= 1
				for i, v in values :: { boolean } do
					buffer.writeu8(blob, cursor + i, if v then 0x01 else 0x00)
				end
			elseif ty == "Int32" then
				writer.i32_array(blob, cursor, values :: { number })
			elseif ty == "Float32" then
				writer.f32_array(blob, cursor, values :: { number })
			elseif ty == "Float64" then
				cursor -= 8
				for i, v in values :: { number } do
					buffer.writef64(blob, cursor + i * 8, v)
				end
			elseif ty == "UDim" then
				print("properties of type UDim are not yet implemented")
			elseif ty == "UDim2" then
				print("properties of type UDim2 are not yet implemented")
			elseif ty == "Ray" then
				print("properties of type Ray are not yet implemented")
			elseif ty == "Faces" then
				print("properties of type Faces are not yet implemented")
			elseif ty == "Axes" then
				print("properties of type Axes are not yet implemented")
			elseif ty == "BrickColor" then
				print("properties of type BrickColor are not yet implemented")
			elseif ty == "Color3" then
				print("properties of type Color3 are not yet implemented")
			elseif ty == "Vector2" then
				print("properties of type Vector2 are not yet implemented")
			elseif ty == "Vector3" then
				local x = table.create(#values) :: { number }
				local y = table.create(#values) :: { number }
				local z = table.create(#values) :: { number }
				for i, v in values :: { vector } do
					x[i] = v.x
					y[i] = v.y
					z[i] = v.z
				end
				cursor = writer.f32_array(blob, cursor, x)
				cursor = writer.f32_array(blob, cursor, y)
				cursor = writer.f32_array(blob, cursor, z)
			elseif ty == "CFrame" then
				print("properties of type CFrame are not yet implemented")
			elseif ty == "Enum" then
				print("properties of type Enum are not yet implemented")
			elseif ty == "Referent" then
				print("properties of type Referent are not yet implemented")
			elseif ty == "Vector3int16" then
				print("properties of type Vector3int16 are not yet implemented")
			elseif ty == "NumberSequence" then
				print("properties of type NumberSequence are not yet implemented")
			elseif ty == "ColorSequence" then
				print("properties of type ColorSequence are not yet implemented")
			elseif ty == "NumberRange" then
				print("properties of type NumberRange are not yet implemented")
			elseif ty == "Rect" then
				print("properties of type Rect are not yet implemented")
			elseif ty == "PhysicalProperties" then
				print("properties of type PhysicalProperties are not yet implemented")
			elseif ty == "Color3uint8" then
				print("properties of type Color3uint8 are not yet implemented")
			elseif ty == "Int64" then
				print("properties of type Int64 are not yet implemented")
			elseif ty == "SharedString" then
				print("properties of type SharedString are not yet implemented")
			elseif ty == "Bytecode" then
				print("properties of type Bytecode are not yet implemented")
			elseif ty == "OptionalCoordinateFrame" then
				print("properties of type OptionalCoordinateFrame are not yet implemented")
			elseif ty == "UniqueId" then
				print("properties of type UniqueId are not yet implemented")
			elseif ty == "Font" then
				print("properties of type Font are not yet implemented")
			elseif ty == "SecurityCapabilities" then
				print("properties of type SecurityCapabilities are not yet implemented")
			elseif ty == "Content" then
				print("properties of type Content are not yet implemented")
			else
				error(`unknown property type {ty}`, 2)
			end
			table.insert(chunks, blob)

			table.clear(values)
		end

		table.clear(prop_list)
		table.clear(prop_map)
	end

	return chunks, sstr_list
end

local function encode_SSTR(sstr_list: { string }): buffer
	local len = 8 -- 4 for version, 4 for count
	for _, v in sstr_list do
		len += #v + 20 -- 4 for len, 16 for hash
	end
	local blob = buffer.create(len)
	buffer.writeu32(blob, 0, SSTR_VERSION)
	buffer.writeu32(blob, 4, #sstr_list)
	local cursor = 8
	for _, v in sstr_list do
		-- We do not write a hash here because this mimics the behavior of
		-- rbx-binary.
		cursor = writer.string(blob, cursor + 16, v)
	end

	return blob
end

local function encode_PRNT(dom: dom.DOM, collected_classes: { CollectedClass }): buffer
	-- TODO: We probably want to collect these
	-- the same way Roblox and rbx-binary does
	-- but that means redoing how we do INST chunks
	local inst_count = 0
	for _ in dom.instances do
		inst_count += 1
	end
	local prnt_list = {}
	local to_visit = table.clone(dom.roots)
	while next(to_visit) ~= nil do
		local referent = table.remove(to_visit, 1) :: referent.Referent
		local inst = dom.instances[referent]
		for _, v in inst.Children do
			prnt_list[v.Id] = referent
			table.insert(to_visit, v.Id)
		end
	end
	local blob = buffer.create(5 + inst_count * 8)
	buffer.writeu8(blob, 0, PRNT_VERSION)
	buffer.writeu32(blob, 1, inst_count)

	return blob
end

local function encode(dom: dom.DOM, compression_type: compress.CompressionType?): buffer
	compression_type = compression_type or "Lz4" :: "Lz4"

	-- INST chunk counters
	local collected_classes: { [string]: CollectedClass } = {}
	local collected_class_count = 0

	local metadata = {
		["ExplicitAutoJoints"] = "true",
	}

	local inst_count = 0
	for referent, instance in dom.instances do
		local class_data: CollectedClass = collected_classes[instance.ClassName]
		if not class_data then
			class_data = {
				ClassName = instance.ClassName,
				TypeId = 0,
				Referents = {},
			}
			collected_class_count += 1
			collected_classes[instance.ClassName] = class_data
		end
		table.insert(class_data.Referents, referent)
		inst_count += 1
	end

	local sorted_data = table.create(collected_class_count - 1) :: { CollectedClass }
	for _, v in collected_classes do
		table.sort(v.Referents, referent_sort)
		table.insert(sorted_data, v)
	end
	table.sort(sorted_data, inst_sort)
	print("Collected class data:", sorted_data)

	local META_chunk = encode_META(metadata)
	local INST_chunks = encode_INSTs(sorted_data)
	local PROP_chunks, sstr_list = encode_PROPs(dom, sorted_data)
	local SSTR_chunk
	local PRNT_chunk = encode_PRNT(dom, sorted_data)
	local END_chunk = buffer.fromstring(END_CONTENT)

	local compressor: (buffer) -> (buffer, number) = if compression_type == "None"
		then compress.none_encode
		elseif compression_type == "Lz4" then compress.lz4_encode
		elseif compression_type == "Zstd" then compress.zstd_encode
		else compress.lz4_encode

	local compressed_META, compressed_META_len = compressor(META_chunk)
	local compressed_SSTR, compressed_SSTR_len
	local compressed_PRNT, compressed_PRNT_len = compressor(PRNT_chunk)
	local compressed_INST_chunks, compressed_INST_len = table.create(#INST_chunks) :: { buffer }, 0
	for i, chunk in INST_chunks do
		local compressed, len = compressor(chunk)
		compressed_INST_chunks[i] = compressed
		compressed_INST_len += len
	end
	local compressed_PROP_chunks, compressed_PROP_len = table.create(#PROP_chunks) :: { buffer }, 0
	for i, chunk in PROP_chunks do
		local compressed, len = compressor(chunk)
		compressed_PROP_chunks[i] = compressed
		compressed_PROP_len += len
	end

	local chunk_count = 3 + #INST_chunks + #PROP_chunks
	local length = MAGIC_NUMBER_LEN
		+ 18
		+ compressed_META_len
		+ compressed_INST_len
		+ compressed_PROP_len
		+ compressed_PRNT_len
		+ END_CONTENT_LEN
		+ (16 * chunk_count)

	if next(sstr_list) ~= nil then
		SSTR_chunk = encode_SSTR(sstr_list)
		compressed_SSTR, compressed_SSTR_len = compressor(SSTR_chunk)
		length += compressed_SSTR_len + 16
	end

	local blob = buffer.create(length)
	buffer.writestring(blob, 0, MAGIC_NUMBER)
	buffer.writeu16(blob, MAGIC_NUMBER_LEN, SUPPORTED_VERSION)
	buffer.writei32(blob, MAGIC_NUMBER_LEN + 2, #INST_chunks)
	buffer.writei32(blob, MAGIC_NUMBER_LEN + 6, inst_count)

	local cursor =
		writer.chunk(blob, MAGIC_NUMBER_LEN + 18, "META", compressed_META, buffer.len(META_chunk), compression_type)
	if next(sstr_list) ~= nil then
		assert(SSTR_chunk, "SSTR chunk was not serialized")
		assert(compressed_SSTR, "SSTR chunk was not compressed")
		cursor = writer.chunk(blob, cursor, "SSTR", compressed_SSTR, buffer.len(SSTR_chunk), compression_type)
	end
	for i, chunk in compressed_INST_chunks do
		cursor = writer.chunk(blob, cursor, "INST", chunk, buffer.len(INST_chunks[i]), compression_type)
	end
	for i, chunk in compressed_PROP_chunks do
		cursor = writer.chunk(blob, cursor, "PROP", chunk, buffer.len(PROP_chunks[i]), compression_type)
	end
	cursor = writer.chunk(blob, cursor, "PRNT", compressed_PRNT, buffer.len(PRNT_chunk), compression_type)
	cursor = writer.chunk(blob, cursor, "END\0", END_chunk, END_CONTENT_LEN, compression_type)

	return blob
end

return encode
