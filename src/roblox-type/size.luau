local types = require("./types")

local size: { [types.RobloxType]: <T>(values: { T }) -> number } = {}

function size.String(values: { string }): number
	local summed = 0
	for _, v in values do
		summed += #v + 4
	end
	return summed
end

function size.Bool(values: { boolean }): number
	return #values
end

function size.Int32(values: { number }): number
	return #values * 4
end

function size.Float32(values: { number }): number
	return #values * 4
end

function size.Float64(values: { number }): number
	return #values * 8
end

function size.Vector3(values: { vector }): number
	return #values * 12
end

return size
