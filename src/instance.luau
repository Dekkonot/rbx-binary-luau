local referent = require("./referent")
local RobloxType = require("./roblox-type")

local Instance = {}

export type Instance = {
	read ClassName: string,
	read Properties: { [string]: RobloxType.RobloxValue },
	read Children: { Instance },
	read Id: referent.Referent,
}

function Instance.new(class_name: string): Instance
	return table.freeze({
		ClassName = class_name,
		Properties = {},
		Children = {},
		Id = referent.new(),
	})
end

return Instance
