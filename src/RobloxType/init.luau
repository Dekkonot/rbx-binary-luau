export type RobloxTypes =
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

export type RobloxType = {
	ty: RobloxTypes,
	data: unknown,
}

local RobloxType = {}

function RobloxType.variant(ty: RobloxTypes, value: unknown): RobloxType
	return {
		ty = ty,
		data = value,
	}
end

return RobloxType
