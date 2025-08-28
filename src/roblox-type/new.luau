local types = require("./types")
local brickcolor = require("./brickcolor")
local referent = require("../referent")
local font = require("./font")

local new = {}

function new.String(value: string): types.RobloxValue
	return {
		ty = "String",
		value = value,
	}
end

function new.Bool(value: boolean): types.RobloxValue
	return {
		ty = "Bool",
		value = value,
	}
end

-- TODO: Do we want to enforce the invariants of number types?
function new.Int32(value: number): types.RobloxValue
	return {
		ty = "Int32",
		value = value,
	}
end

function new.Float32(value: number): types.RobloxValue
	return {
		ty = "Float32",
		value = value,
	}
end

function new.Float64(value: number): types.RobloxValue
	return {
		ty = "Float64",
		value = value,
	}
end

function new.UDim(scale: number, offset: number): types.RobloxValue
	return {
		ty = "UDim",
		value = { Scale = scale, Offset = offset },
	}
end

function new.UDim2(x_scale: number, x_offset: number, y_scale: number, y_offset: number): types.RobloxValue
	return {
		ty = "UDim2",
		value = {
			X = { Scale = x_scale, Offset = x_offset },
			Y = { Scale = y_scale, Offset = y_offset },
		},
	}
end

function new.Ray(origin: vector, direction: vector): types.RobloxValue
	return {
		ty = "Ray",
		value = {
			Origin = origin,
			Direction = direction,
		},
	}
end

function new.Faces(
	front: boolean,
	bottom: boolean,
	left: boolean,
	back: boolean,
	top: boolean,
	right: boolean
): types.RobloxValue
	return {
		ty = "Faces",
		value = {
			Front = front,
			Bottom = bottom,
			Left = left,
			Back = back,
			Top = top,
			Right = right,
		},
	}
end

function new.Axes(x: boolean, y: boolean, z: boolean): types.RobloxValue
	return {
		ty = "Axes",
		value = {
			X = x,
			Y = y,
			Z = z,
		},
	}
end

function new.BrickColor(value: number): types.RobloxValue
	if not brickcolor[value] then
		error(`unknown BrickColor code {value}`)
	end
	return {
		ty = "BrickColor",
		value = value,
	}
end

function new.Color3(value: vector): types.RobloxValue
	return {
		ty = "Color3",
		value = value,
	}
end

function new.Vector2(x: number, y: number): types.RobloxValue
	return {
		ty = "Vector2",
		value = {
			X = x,
			Y = y,
		},
	}
end

function new.Vector3(value: vector): types.RobloxValue
	return {
		ty = "Vector3",
		value = value,
	}
end

function new.CFrame(): types.RobloxValue
	error("CFrames are unimplemented")
end

function new.Enum(value: number): types.RobloxValue
	return {
		ty = "Enum",
		value = value,
	}
end

function new.Referent(value: referent.Referent): types.RobloxValue
	return {
		ty = "Referent",
		value = value,
	}
end

function new.Vector3int16(value: vector): types.RobloxValue
	return {
		ty = "Vector3int16",
		value = value,
	}
end

function new.NumberSequence(): types.RobloxValue
	error("NumberSequences are unimplemented")
end

function new.ColorSequencee(): types.RobloxValue
	error("ColorSequences are unimplemented")
end

function new.NumberRange(min: number, max: number): types.RobloxValue
	return {
		ty = "NumberRange",
		value = {
			Min = min,
			Max = max,
		},
	}
end

function new.Rect(min_x: number, min_y: number, max_x: number, max_y: number): types.RobloxValue
	return {
		ty = "Rect",
		value = {
			Min = { X = min_x, Y = min_y },
			Max = { X = max_x, Y = max_y },
		},
	}
end

function new.PhysicalProperties(): types.RobloxValue
	error("PhysicalProperties values are unimplemented")
end

function new.Color3uint8(value: vector): types.RobloxValue
	return {
		ty = "Color3uint8",
		value = value,
	}
end

function new.Int64(): types.RobloxValue
	error("Int64s are unimplemented")
end

function new.SharedString(value: buffer): types.RobloxValue
	return {
		ty = "SharedString",
		value = value,
	}
end

function new.Bytecode(value: buffer): types.RobloxValue
	return {
		ty = "Bytecode",
		value = value,
	}
end

function new.OptionalCoordinateFrame(): types.RobloxValue
	error("OptionalCoordinateFrames are unimplemented")
end

function new.UniqueId(value: buffer): types.RobloxValue
	return {
		ty = "UniqueId",
		value = value,
	}
end

function new.Font(
	family: string,
	weight: font.FontWeight,
	style: font.FontStyle,
	cached_face_id: string?
): types.RobloxValue
	return {
		ty = "Font",
		value = {
			Family = family,
			Weight = weight,
			Style = style,
			CachedFaceId = cached_face_id,
		},
	}
end

function new.SecurityCapabilities(): types.RobloxValue
	error("SecurityCapabilities values are unimplemented")
end

function new.Content(inner_value: (string | referent.Referent)?): types.RobloxValue
	return {
		ty = "Content",
		value = {
			IsUri = type(inner_value) == "string",
			Value = inner_value,
		},
	}
end

return new
