local LZ4_MAGIC_NUMBER = "\x04\x22\x4d\x18"
local ZSTD_MAGIC_NUMBER = "\x28\xb5\x2f\xfd"

local compress = {}

compress.LZ4_MAGIC_NUMBER = LZ4_MAGIC_NUMBER
compress.ZSTD_MAGIC_NUMBER = ZSTD_MAGIC_NUMBER

function compress.lz4_encode(input: buffer): buffer
	local serde = require("@lune/serde")
	return buffer.fromstring(serde.compress("lz4", input))
end

function compress.lz4_decode(input: buffer, output_size: number): buffer
	assert(output_size, "you must provide the output size to decompress data")
	local serde = require("@lune/serde")

	-- Lune expects a frame, but Roblox's format uses a block.
	-- Rather than implementing it manually, we just make a frame manually.
	-- https://github.com/lz4/lz4/blob/dev/doc/lz4_Frame_format.md
	local frame_data = buffer.create(buffer.len(input) + 19)
	-- ...Lune also prefixes the length.
	buffer.writeu32(frame_data, 0, output_size)
	buffer.writestring(frame_data, 4, LZ4_MAGIC_NUMBER)
	buffer.writestring(frame_data, 8, "\x60\x60\x51")
	-- This will run into trouble a block is over 0x7fff_ffff bytes
	buffer.writeu32(frame_data, 11, buffer.len(input))
	buffer.copy(frame_data, 15, input)

	return buffer.fromstring(serde.decompress("lz4", frame_data))
end

function compress.zstd_encode(input: buffer): buffer
	error("zstd encoding support is not yet implemented")
end

function compress.zstd_decode(input: buffer, output_size: number): buffer
	assert(output_size, "you must provide the output size to decompress data")
	error("zstd decoding support is not yet implemented")
end

return compress
