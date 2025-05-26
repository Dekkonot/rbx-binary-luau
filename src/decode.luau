local instance = require("./instance")
local referent = require("./referent")
local dom = require("./dom")
local compress = require("./compress")
local constants = require("./constants")
local reader = require("./reader")
local RobloxType = require("./roblox-type")

local MAGIC_NUMBER = constants.MAGIC_NUMBER
local MAGIC_NUMBER_LEN = #MAGIC_NUMBER

local SUPPORTED_VERSION = constants.SUPPORTED_VERSION
local SSTR_VERSION = constants.SSTR_VERSION
local PRNT_VERSION = constants.PRNT_VERSION

local END_CONTENT = constants.END_CONTENT
local END_CONTENT_LEN = #END_CONTENT

type Chunk = {
	name: string,
	blob: buffer,
}

local function dump_hex(blob: buffer, starting_at: number?)
	local tab: { string } = {}
	for i = starting_at or 0, buffer.len(blob) - 1 do
		table.insert(tab, string.format("%02x", buffer.readu8(blob, i)))
	end
	print(table.concat(tab, " "))
end

local function parse_META(blob: buffer): { [string]: string }
	print("Parsing META")
	local count = buffer.readu32(blob, 0)
	local entries = {}
	local cursor = 4
	local key: string, value: string
	for _ = 1, count do
		cursor, key = reader.string(blob, cursor)
		cursor, value = reader.string(blob, cursor)
		print(`  {key} = {value}`)
		entries[key] = value
	end

	return entries
end

local function parse_SSTR(blob: buffer): { string }
	print("Parsing SSTR")
	local version = buffer.readu32(blob, 0)
	if version ~= SSTR_VERSION then
		error(
			`cannot read binary file: the SSTR chunk is the wrong version (expected {SSTR_VERSION}, got {version})`,
			2
		)
	end
	local count = buffer.readu32(blob, 4)
	local strings = table.create(count) :: { string }

	local cursor = 8
	local sstr: string
	for i = 1, count do
		local _hash = buffer.readstring(blob, cursor, 16)
		-- And this is where we'd validate the hash if we cared to.
		cursor, sstr = reader.string(blob, cursor + 16)
		print(`  sstr #{i} = {#sstr} bytes`)
		strings[i] = sstr
	end

	return strings
end

local function parse_INST(
	blob: buffer,
	class_id_lists: { [number]: { number } },
	referent_to_instance: { [number]: instance.Instance }
)
	print("Parsing INST")
	local class_id = buffer.readu32(blob, 0)
	local cursor, class_name = reader.string(blob, 4)
	print(`  class_id: {class_id}`)
	print(`  class_name: {class_name}`)

	local chunk_format = buffer.readu8(blob, cursor)
	if chunk_format ~= 0 and chunk_format ~= 1 then
		error(`cannot read binary file: INST chunk {class_id} is of an unknown type {chunk_format}`, 2)
	end
	local instance_count = buffer.readu32(blob, cursor + 1)
	local referents
	print(`  count: {instance_count}`)
	cursor, referents = reader.referent_array(blob, cursor + 5, instance_count)
	-- In theory if the chunk format is `1` we need to check for
	-- 'service markers' but in practice I don't know if we have to
	-- do that. We don't in rbx-binary and it's been fine. It might be
	-- a Roblox implementation detail that leaked into the format.

	class_id_lists[class_id] = referents

	print(`  referents:`)
	for _, referent in referents do
		print(`    - {referent}`)
		local instance = instance.new(class_name)
		referent_to_instance[referent] = instance
	end
	class_id_lists[class_id] = referents
end

local function parse_PROP(
	blob: buffer,
	class_id_lists: { [number]: { number } },
	referent_to_instance: { [number]: instance.Instance },
	shared_strings: { [number]: string }
)
	print("Parsing PROP")
	local class_id = buffer.readu32(blob, 0)
	local cursor, prop_name = reader.string(blob, 4)
	print(`  class_id: {class_id}`)
	print(`  prop_name: {prop_name}`)
	local type_id = buffer.readu8(blob, cursor)
	cursor += 1
	print(`  type_id: {string.format("%02x", type_id)}`)
	local referent_list = class_id_lists[class_id]
	if not referent_list then
		error(`cannot read binary file: PROP chunk references unknown INST chunk {class_id}`, 2)
	end
	if type_id == 0x01 then
		local read_value: string
		for i, referent in referent_list do
			cursor, read_value = reader.string(blob, cursor)
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.string(read_value)
		end
	elseif type_id == 0x02 then
		for i, referent in referent_list do
			local read_value = buffer.readu8(blob, cursor)
			cursor += 1
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.bool(read_value ~= 0x00)
		end
	elseif type_id == 0x03 then
		local values: { number }
		cursor, values = reader.i32_array(blob, cursor, #referent_list)
		for i, referent in referent_list do
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.int32(values[i])
		end
	elseif type_id == 0x04 then
		local values: { number }
		cursor, values = reader.f32_array(blob, cursor, #referent_list)
		for i, referent in referent_list do
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.float32(values[i])
		end
	elseif type_id == 0x05 then
		for i, referent in referent_list do
			local read_value = buffer.readf64(blob, cursor)
			cursor += 1
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.float64(read_value)
		end
	elseif type_id == 0x06 then
		print("properties of type UDim are not yet implemented")
	elseif type_id == 0x07 then
		print("properties of type UDim2 are not yet implemented")
	elseif type_id == 0x08 then
		print("properties of type Ray are not yet implemented")
	elseif type_id == 0x09 then
		print("properties of type Faces are not yet implemented")
	elseif type_id == 0x0a then
		print("properties of type Axes are not yet implemented")
	elseif type_id == 0x0b then
		print("properties of type BrickColor are not yet implemented")
	elseif type_id == 0x0c then
		print("properties of type Color3 are not yet implemented")
	elseif type_id == 0x0d then
		print("properties of type Vector2 are not yet implemented")
	elseif type_id == 0x0e then
		local x: { number }, y: { number }, z: { number }
		cursor, x = reader.f32_array(blob, cursor, #referent_list)
		cursor, y = reader.f32_array(blob, cursor, #referent_list)
		cursor, z = reader.f32_array(blob, cursor, #referent_list)
		for i, referent in referent_list do
			local inst = referent_to_instance[referent]
			inst.Properties[prop_name] = RobloxType.new.vector3(vector.create(x[i], y[i], z[i]))
		end
	elseif type_id == 0x0f then
		print("properties of type ??? are not yet implemented")
	elseif type_id == 0x10 then
		print("properties of type CFrame are not yet implemented")
	elseif type_id == 0x11 then
		print("properties of type ??? are not yet implemented")
	elseif type_id == 0x12 then
		print("properties of type Enum are not yet implemented")
	elseif type_id == 0x13 then
		print("properties of type Referent are not yet implemented")
	elseif type_id == 0x14 then
		print("properties of type Vector3int16 are not yet implemented")
	elseif type_id == 0x15 then
		print("properties of type NumberSequence are not yet implemented")
	elseif type_id == 0x16 then
		print("properties of type ColorSequence are not yet implemented")
	elseif type_id == 0x17 then
		print("properties of type NumberRange are not yet implemented")
	elseif type_id == 0x18 then
		print("properties of type Rect are not yet implemented")
	elseif type_id == 0x19 then
		print("properties of type PhysicalProperties are not yet implemented")
	elseif type_id == 0x1a then
		print("properties of type Color3uint8 are not yet implemented")
	elseif type_id == 0x1b then
		print("properties of type Int64 are not yet implemented")
	elseif type_id == 0x1c then
		print("properties of type SharedString are not yet implemented")
	elseif type_id == 0x1d then
		print("properties of type Bytecode are not yet implemented")
	elseif type_id == 0x1e then
		print("properties of type OptionalCFrame are not yet implemented")
	elseif type_id == 0x1f then
		print("properties of type UniqueId are not yet implemented")
	elseif type_id == 0x20 then
		print("properties of type Font are not yet implemented")
	elseif type_id == 0x21 then
		print("properties of type SecurityCapabilities are not yet implemented")
	elseif type_id == 0x22 then
		print("properties of type Content are not yet implemented")
	end
end

local function parse_PRNT(
	blob: buffer,
	referent_to_instance: { [number]: instance.Instance },
	roots: { referent.Referent }
)
	print("Parsing PRNT")
	local version = buffer.readu8(blob, 0)
	if version ~= PRNT_VERSION then
		error(
			`cannot read binary file: the PRNT chunk is the wrong version (expected {PRNT_VERSION}, got {version})`,
			2
		)
	end
	local inst_count = buffer.readu32(blob, 1)
	print(`  inst_count: {inst_count}`)
	local cursor
	local children, parents
	cursor, children = reader.referent_array(blob, 5, inst_count)
	cursor, parents = reader.referent_array(blob, cursor, inst_count)
	print("  relationships:")
	for i, child in children do
		local parent = parents[i]
		local child_instance = referent_to_instance[child]
		if parent == -1 then
			table.insert(roots, child_instance.Id)
		else
			table.insert(referent_to_instance[parent].Children, child_instance)
		end
		print(`    - {child} -> {parent}`)
	end
end

local function parse_END(blob: buffer)
	print("Parsing END")
	local len = buffer.len(blob)
	if len ~= END_CONTENT_LEN then
		error("cannot read binary file: the END chunk is the incorrect length", 2)
	end
	local content = buffer.tostring(blob)
	if content ~= END_CONTENT then
		error("cannot read binary file: the END chunk content was not correct", 2)
	end
end

function decode(blob: buffer): dom.DOM
	local blob_len = buffer.len(blob)
	-- TODO: Ensure buffer is at least the length of the shortest possible file
	local metadata = {}
	local shared_strings = {}

	local read_header = buffer.readstring(blob, 0, MAGIC_NUMBER_LEN)
	if read_header ~= MAGIC_NUMBER then
		error("cannot read binary file: magic number of blob is not correct")
	end
	local version = buffer.readu16(blob, MAGIC_NUMBER_LEN)
	if version ~= SUPPORTED_VERSION then
		error(
			`cannot read binary file: this parser only supports version {SUPPORTED_VERSION} and this file is version {version}`
		)
	end

	-- TODO: use these to verify correctness
	local _class_count = buffer.readi32(blob, MAGIC_NUMBER_LEN + 2)
	local _instance_count = buffer.readi32(blob, MAGIC_NUMBER_LEN + 6)

	local header_reserved = buffer.readf64(blob, MAGIC_NUMBER_LEN + 10)
	if header_reserved ~= 0 then
		print("warning: reserved space in binary file header was not all 0s")
	end

	local chunks: { Chunk } = {}

	local cursor = MAGIC_NUMBER_LEN + 18
	while cursor <= blob_len do
		local chunk_name = buffer.readstring(blob, cursor, 4)
		local compressed_length = buffer.readu32(blob, cursor + 4)
		local decompressed_length = buffer.readu32(blob, cursor + 8)
		local reserved = buffer.readu32(blob, cursor + 12)

		if reserved ~= 0 then
			print(`warning: reserved space in chunk #{#chunks + 1} was not all 0s`)
		end

		local chunk_blob
		if compressed_length == 0 then
			-- Uncompressed
			chunk_blob = buffer.create(decompressed_length)
			buffer.copy(chunk_blob, 0, blob, cursor + 16, decompressed_length)
			cursor += decompressed_length + 16
		else
			local compressed = buffer.create(compressed_length)
			buffer.copy(compressed, 0, blob, cursor + 16, compressed_length)
			cursor += compressed_length + 16

			local is_zstd = buffer.readstring(compressed, 0, 4)
			if is_zstd == compress.ZSTD_MAGIC_NUMBER then
				chunk_blob = compress.zstd_decode(compressed, decompressed_length)
			else
				chunk_blob = compress.lz4_decode(compressed, decompressed_length)
			end
		end
		table.insert(chunks, {
			name = chunk_name,
			blob = chunk_blob,
		})

		if chunk_name == "END\0" then
			break
		end
	end

	--- Map of `class_id` to an array of file-specific referents
	local class_id_lists: { [number]: { number } } = {}
	--- Map of file-specific referents to their Instances
	local referent_to_instance: { [number]: instance.Instance } = {}

	local roots: { referent.Referent } = {}

	for i, chunk in chunks do
		local chunk_name: string = chunk.name
		if chunk_name == "META" then
			if next(metadata) ~= nil then
				error(`cannot read binary file: there are multiple META chunks in this file`)
			end
			metadata = parse_META(chunk.blob)
		elseif chunk_name == "SSTR" then
			if next(shared_strings) ~= nil then
				error(`cannot read binary file: there are multiple SSTR chunks in this file`)
			end
			shared_strings = parse_SSTR(chunk.blob)
		elseif chunk_name == "INST" then
			parse_INST(chunk.blob, class_id_lists, referent_to_instance)
		elseif chunk_name == "PROP" then
			parse_PROP(chunk.blob, class_id_lists, referent_to_instance, shared_strings)
		elseif chunk_name == "PRNT" then
			parse_PRNT(chunk.blob, referent_to_instance, roots)
		elseif chunk_name == "END\0" then
			parse_END(chunk.blob)
		else
			local name_bytes = table.create(4) :: { string }
			for j = 1, 4 do
				name_bytes[j] = string.format("%02x", string.byte(chunk_name, j, j))
			end
			print(`warning: chunk #{i} is of an unknown type ({chunk_name} OR {table.concat(name_bytes, " ")})`)
		end
	end

	local instances_collected = {}
	for _, v in referent_to_instance do
		instances_collected[v.Id] = v
	end

	return dom.fromParts(instances_collected, roots)
end

return decode
