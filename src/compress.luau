local LZ4_MAGIC_NUMBER = "\x04\x22\x4d\x18"
local ZSTD_MAGIC_NUMBER = "\x28\xb5\x2f\xfd"

export type CompressionType = "None" | "Lz4" | "Zstd"

local compress = {}

compress.LZ4_MAGIC_NUMBER = LZ4_MAGIC_NUMBER
compress.ZSTD_MAGIC_NUMBER = ZSTD_MAGIC_NUMBER

function compress.lz4_encode(input: buffer): (buffer, number)
	local lz4 = require("./vendor/lz4")
	local compressed = lz4.compress(buffer.tostring(input), 6)
	return buffer.fromstring(compressed), #compressed
end

function compress.lz4_decode(input: buffer, output_size: number): buffer
	assert(output_size, "you must provide the output size to decompress data")
	local lz4 = require("./vendor/lz4")

	local decompressed: buffer, decompressed_len: number =
		lz4.decompressBuffer(input, 0, buffer.len(input), output_size)
	local result = buffer.create(decompressed_len)
	buffer.copy(result, 0, decompressed, 0, decompressed_len)
	return result
end

function compress.zstd_encode(input: buffer): (buffer, number)
	error("zstd encoding support is not yet implemented")
end

function compress.zstd_decode(input: buffer, output_size: number): buffer
	assert(output_size, "you must provide the output size to decompress data")
	error("zstd decoding support is not yet implemented")
end

function compress.none_encode(input: buffer): (buffer, number)
	return input, buffer.len(input)
end

function compress.none_decode(input: buffer): buffer
	return input
end

return compress
