local types = require("./types")

local size: { [types.RobloxType]: <T>(values: { T }) -> number } = {}

function size.String(values: { types.String }): number
	local summed = 0
	for _, v in values do
		summed += #v + 4
	end
	return summed
end

function size.Bool(values: { types.Bool }): number
	return #values
end

function size.Int32(values: { types.Int32 }): number
	return #values * 4
end

function size.Float32(values: { types.Float32 }): number
	return #values * 4
end

function size.Float64(values: { types.Float64 }): number
	return #values * 8
end

function size.UDim(values: { types.UDim }): number
	return #values * 8
end

function size.UDim2(values: { types.UDim2 }): number
	return #values * 16
end

function size.Ray(values: { types.Ray }): number
	return #values * 24
end

function size.Faces(values: { types.Faces }): number
	return #values
end

function size.Axes(values: { types.Axes }): number
	return #values
end

function size.BrickColor(values: { types.BrickColor }): number
	return #values * 4
end

function size.Color3(values: { types.Color3 }): number
	return #values * 12
end

function size.Vector2(values: { types.Vector2 }): number
	return #values * 8
end

function size.Vector3(values: { types.Vector3 }): number
	return #values * 12
end

function size.CFrame(values: { types.CFrame }): number
	error("sizing for CFrame type is not implemented")
end

function size.Enum(values: { types.Enum }): number
	return #values * 4
end

function size.Referent(values: { types.Referent }): number
	return #values * 4
end

return size
