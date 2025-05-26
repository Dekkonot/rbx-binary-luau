local types = require("./types")

local new = {}

function new.string(value: string): types.RobloxValue
	return {
		ty = "String",
		value = value,
	}
end

function new.bool(value: boolean): types.RobloxValue
	return {
		ty = "Bool",
		value = value,
	}
end

-- TODO: Do we want to enforce the invariants of number types?
function new.int32(value: number): types.RobloxValue
	return {
		ty = "Int32",
		value = value,
	}
end

function new.float32(value: number): types.RobloxValue
	return {
		ty = "Float32",
		value = value,
	}
end

function new.float64(value: number): types.RobloxValue
	return {
		ty = "Float64",
		value = value,
	}
end

function new.vector3(value: vector): types.RobloxValue
	return {
		ty = "Vector3",
		value = value,
	}
end

return new
