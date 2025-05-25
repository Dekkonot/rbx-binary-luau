export type RobloxType =
	| "String"
	| "Bool"
	| "Int32"
	| "Float32"
	| "Float64"
	| "UDim"
	| "UDim2"
	| "Ray"
	| "Faces"
	| "Axes"
	| "BrickColor"
	| "Color3"
	| "Vector2"
	| "Vector3"
	| "CFrame"
	-- Quaternion?
	| "Enum"
	| "Referent"
	| "Vector3int16"
	-- Vector2int16?
	| "NumberSequence"
	| "ColorSequence"
	| "NumberRange"
	| "Rect"
	| "PhysicalProperties"
	| "Color3uint8"
	| "Int64"
	| "SharedString"
	| "Bytecode"
	| "OptionalCoordinateFrame"
	| "UniqueId"
	| "Font"
	| "SecurityCapabilities"
	| "Content"

export type RobloxValue = {
	ty: RobloxType,
	data: unknown,
}

local RobloxType = {}

function RobloxType.string(value: string): RobloxValue
	return {
		ty = "String",
		value = value,
	}
end

function RobloxType.bool(value: boolean): RobloxValue
	return {
		ty = "Bool",
		value = value,
	}
end

-- TODO: Do we want to enforce the invariants of number types?
function RobloxType.int32(value: number): RobloxValue
	return {
		ty = "Int32",
		value = value,
	}
end

function RobloxType.float32(value: number): RobloxValue
	return {
		ty = "Float32",
		value = value,
	}
end

function RobloxType.float64(value: number): RobloxValue
	return {
		ty = "Float64",
		value = value,
	}
end

function RobloxType.vector3(value: vector): RobloxValue
	return {
		ty = "Vector3",
		value = value,
	}
end

return RobloxType
