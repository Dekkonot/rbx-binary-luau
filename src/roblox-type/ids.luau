local types = require("./types")

local from_type: { [types.RobloxType]: number } = {
	["String"] = 0x01,
	["Bool"] = 0x02,
	["Int32"] = 0x03,
	["Float32"] = 0x04,
	["Float64"] = 0x05,
	["UDim"] = 0x06,
	["UDim2"] = 0x07,
	["Ray"] = 0x08,
	["Faces"] = 0x09,
	["Axes"] = 0x0a,
	["BrickColor"] = 0x0b,
	["Color3"] = 0x0c,
	["Vector2"] = 0x0d,
	["Vector3"] = 0x0e,
	-- ???
	["CFrame"] = 0x10,
	-- ???
	["Enum"] = 0x12,
	["Referent"] = 0x13,
	["Vector3int16"] = 0x14,
	["NumberSequence"] = 0x15,
	["ColorSequence"] = 0x16,
	["NumberRange"] = 0x17,
	["Rect"] = 0x18,
	["PhysicalProperties"] = 0x19,
	["Color3uint8"] = 0x1a,
	["Int64"] = 0xb,
	["SharedString"] = 0x1c,
	["Bytecode"] = 0x1d,
	["OptionalCoordinateFrame"] = 0x1e,
	["UniqueId"] = 0x1f,
	["Font"] = 0x20,
	["SecurityCapabilities"] = 0x21,
	["Content"] = 0x22,
}

-- TODO: Add a `from_id` type so we don't have to hardcode things
-- We cannot at the moment because it resolves into an unusable type.
-- See this Luau bug: https://github.com/luau-lang/luau/issues/1851

local ids = {}
ids.from_type = from_type

return ids
