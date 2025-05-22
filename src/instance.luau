local referent = require("./referent")
local RobloxType = require("./RobloxType")

local Instance = {}

export type Instance = {
	read ClassName: string,
	read Properties: { [string]: RobloxType.RobloxType },
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
