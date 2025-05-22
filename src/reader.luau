local temporary_storage = buffer.create(4)

@native
local function untransform_i32(n: number): number
	-- This is in two parts:
	-- one is bit32.bxor(bit32.rshift(n, 1), -bit32.band(n, 1))
	-- and the other is bit32.bxor(n, 0x80000000) - 0x80000000
	-- The former is to untransform the integer
	-- The other is to convert it from a u32 to an i32
	return bit32.bxor(bit32.bxor(bit32.rshift(n, 1), -bit32.band(n, 1)), 0x80000000) - 0x80000000
end

local Reader = {}

function Reader.string(buf: buffer, cursor: number): (number, string)
	local len = buffer.readu32(buf, cursor)
	local str = buffer.readstring(buf, cursor + 4, len)
	return cursor + len + 4, str
end

function Reader.f32_array(buf: buffer, cursor: number, len: number): (number, { number })
	local result = table.create(len) :: { number }
	cursor -= 1

	for i = 1, len do
		local b0 = buffer.readu8(buf, cursor + i)
		local b1 = buffer.readu8(buf, cursor + len + i)
		local b2 = buffer.readu8(buf, cursor + len * 2 + i)
		local b3 = buffer.readu8(buf, cursor + len * 3 + i)

		buffer.writeu32(
			temporary_storage,
			0,
			bit32.rrotate(bit32.bor(bit32.lshift(b0, 24), bit32.lshift(b1, 16), bit32.lshift(b2, 8), b3), 1)
		)
		result[i] = buffer.readf32(temporary_storage, 0)
	end

	return cursor + len * 4 + 1, result
end

function Reader.i32_array(buf: buffer, cursor: number, len: number): (number, { number })
	local result = table.create(len) :: { number }
	cursor -= 1

	-- TODO: Is it more efficient to use strings or buffer for this?
	for i = 1, len do
		local b0 = buffer.readu8(buf, cursor + i)
		local b1 = buffer.readu8(buf, cursor + len + i)
		local b2 = buffer.readu8(buf, cursor + len * 2 + i)
		local b3 = buffer.readu8(buf, cursor + len * 3 + i)

		result[i] = untransform_i32(bit32.bor(bit32.lshift(b0, 24), bit32.lshift(b1, 16), bit32.lshift(b2, 8), b3))
	end

	return cursor + len * 4 + 1, result
end

function Reader.referent_array(buf: buffer, cursor: number, len: number): (number, { number })
	local new_cursor, referents = Reader.i32_array(buf, cursor, len)
	local accum = 0
	for i, v in referents do
		referents[i] = v + accum
		accum += v
	end

	return new_cursor, referents
end

return Reader
