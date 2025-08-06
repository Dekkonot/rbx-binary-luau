local RobloxType = require("./roblox-type")

local DEFAULT_VALUES: { [RobloxType.RobloxType]: unknown } = {
	["String"] = "",
	["Bool"] = false,
	["Int32"] = 0,
	["Float32"] = 0,
	["Float64"] = 0,
	-- ["UDim"] = error("no default value defined for type 'UDim'"),
	-- ["UDim2"] = error("no default value defined for type 'UDim2'"),
	-- ["Ray"] = error("no default value defined for type 'Ray'"),
	-- ["Faces"] = error("no default value defined for type 'Faces'"),
	-- ["Axes"] = error("no default value defined for type 'Axes'"),
	-- ["BrickColor"] = error("no default value defined for type 'BrickColor'"),
	-- ["Color3"] = error("no default value defined for type 'Color3'"),
	-- ["Vector2"] = error("no default value defined for type 'Vector2'"),
	["Vector3"] = vector.zero,
	-- ["CFrame"] = error("no default value defined for type 'CFrame'"),
	-- ["Enum"] = error("no default value defined for type 'Enum'"),
	-- ["Referent"] = error("no default value defined for type 'Referent'"),
	-- ["Vector3int16"] = error("no default value defined for type 'Vector3int16'"),
	-- ["NumberSequence"] = error("no default value defined for type 'NumberSequence'"),
	-- ["ColorSequence"] = error("no default value defined for type 'ColorSequence'"),
	-- ["NumberRange"] = error("no default value defined for type 'NumberRange'"),
	-- ["Rect"] = error("no default value defined for type 'Rect'"),
	-- ["PhysicalProperties"] = error("no default value defined for type 'PhysicalProperties'"),
	-- ["Color3uint8"] = error("no default value defined for type 'Color3uint8'"),
	-- ["Int64"] = error("no default value defined for type 'Int64'"),
	-- ["SharedString"] = error("no default value defined for type 'SharedString'"),
	-- ["Bytecode"] = error("no default value defined for type 'Bytecode'"),
	-- ["OptionalCoordinateFrame"] = error("no default value defined for type 'OptionalCoordinateFrame'"),
	-- ["UniqueId"] = error("no default value defined for type 'UniqueId'"),
	-- ["Font"] = error("no default value defined for type 'Font'"),
	-- ["SecurityCapabilities"] = error("no default value defined for type 'SecurityCapabilities'"),
	-- ["Content"] = error("no default value defined for type 'Content'"),
}

local database = {}

function database.default_value(type: RobloxType.RobloxType): RobloxType.RobloxValue
	local value = DEFAULT_VALUES[type]
	if not value then
		-- TODO: Check default from database
		error(`no default value for type {type} is recorded`, 2)
	else
		if typeof(value) == "table" then
			return {
				ty = type,
				data = table.clone(value),
			}
		elseif typeof(value) == "buffer" then
			local copy = buffer.create(buffer.len(value))
			buffer.copy(copy, 0, value)
			return {
				ty = type,
				data = copy,
			}
		else
			return {
				ty = type,
				data = value,
			}
		end
	end
end

return database
