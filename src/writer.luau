local compress = require("./compress")

local temporary_storage = buffer.create(4)

@native
local function transform_i32(n: number): number
	-- (x << 1) ^ (x >> 31)
	return bit32.bxor(bit32.lshift(n, 1), bit32.arshift(n, 31))
end

local Writer = {}

function Writer.string(buf: buffer, cursor: number, str: string): number
	buffer.writeu32(buf, cursor, #str)
	buffer.writestring(buf, cursor + 4, str)
	return cursor + 4 + #str
end

function Writer.f32_array(buf: buffer, cursor: number, array: { number }): number
	local len = #array
	for i, v in array do
		i -= 1
		buffer.writef32(temporary_storage, 0, v)
		v = bit32.lrotate(buffer.readu32(temporary_storage, 0), 1)

		buffer.writeu8(buf, cursor + i, bit32.rshift(v, 24))
		buffer.writeu8(buf, cursor + i + len, bit32.rshift(v, 16))
		buffer.writeu8(buf, cursor + i + len * 2, bit32.rshift(v, 8))
		buffer.writeu8(buf, cursor + i + len * 3, v)
	end

	return cursor + len * 4
end

function Writer.i32_array(buf: buffer, cursor: number, array: { number }): number
	local len = #array
	for i, v in array do
		i -= 1
		v = transform_i32(v)
		buffer.writeu8(buf, cursor + i, bit32.rshift(v, 24))
		buffer.writeu8(buf, cursor + i + len, bit32.rshift(v, 16))
		buffer.writeu8(buf, cursor + i + len * 2, bit32.rshift(v, 8))
		buffer.writeu8(buf, cursor + i + len * 3, v)
	end

	return cursor + len * 4
end

function Writer.referent_array(buf: buffer, cursor: number, referents: { number }): number
	local transformed = table.create(#referents, 0)
	local last = 0
	for i, v in referents do
		transformed[i] = v - last
		last = v
	end

	cursor = Writer.i32_array(buf, cursor, transformed)

	return cursor
end

function Writer.chunk(
	buf: buffer,
	cursor: number,
	chunk_name: string,
	chunk_data: buffer,
	decompressed_len: number,
	compression_type: compress.CompressionType
): number
	buffer.writestring(buf, cursor, chunk_name, 4)
	if compression_type == "None" then -- This is not compressed
		buffer.writeu32(buf, cursor + 4, 0)
	else
		buffer.writeu32(buf, cursor + 4, buffer.len(chunk_data))
	end
	buffer.writeu32(buf, cursor + 8, decompressed_len)
	buffer.copy(buf, cursor + 16, chunk_data)
	return cursor + 16 + buffer.len(chunk_data)
end

return Writer
