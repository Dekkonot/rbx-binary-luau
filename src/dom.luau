local referent = require("./referent")
local instance = require("./instance")

local Dom = {}

export type DOM = {
	read roots: { referent.Referent },
	read instances: { [referent.Referent]: instance.Instance },
}

function Dom.new(root: instance.Instance): DOM
	local dom = {
		instances = { [root.Id] = root },
		roots = { root.Id },
	}

	table.freeze(dom)

	return dom
end

function Dom.fromParts(instances: { [referent.Referent]: instance.Instance }, roots: { referent.Referent }?): DOM
	local dom = {
		instances = instances,
		roots = roots or {},
	}
	table.freeze(dom)

	return dom
end

return Dom
