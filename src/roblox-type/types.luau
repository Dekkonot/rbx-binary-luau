local referent = require("../referent")

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
	value: unknown,
}

export type String = string

export type Bool = boolean

export type Int32 = number

export type Float32 = number

export type Float64 = number

export type UDim = { Scale: number, Offset: number }

export type UDim2 = { X: UDim, Y: UDim }

export type Ray = { Origin: vector, Direction: vector }

export type Faces = {
	Front: boolean,
	Bottom: boolean,
	Left: boolean,
	Back: boolean,
	Top: boolean,
	Right: boolean,
}

export type Axes = {
	X: boolean,
	Y: boolean,
	Z: boolean,
}

export type BrickColor = number

export type Color3 = vector

export type Vector2 = { X: number, Y: number }

export type Vector3 = vector

export type CFrame = never

export type Enum = number

export type Referent = referent.Referent

export type Vector3int16 = vector

export type NumberSequence = never

export type ColorSequence = never

export type NumberRange = {
	Min: number,
	Max: number,
}

export type Rect = {
	Min: { X: number, Y: number },
	Max: { X: number, Y: number },
}

export type PhysicalProperties = never

export type Color3uint8 = { R: number, G: number, B: number }

export type Int64 = never

export type SharedString = buffer

export type Bytecode = buffer

export type OptionalCoordinateFrame = never

export type UniqueId = buffer

export type Font = {
	Family: string,
	Weight: number,
	Style: number,
	CachedFaceId: string?,
}

export type SecurityCapabilites = never

export type Content = {
	IsUri: false,
	Value: referent.Referent,
}

local types = {}

return types
