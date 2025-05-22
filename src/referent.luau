local Referent = {}
local methods = {}

local mt = {}

local REFERENT_COUNT = 1

export type Referent = {
	read id: number,
}

local function hex_string(n: number): string
	return string.format("%016x", n)
end

function Referent.new(): Referent
	local referent = {
		id = REFERENT_COUNT,
	}
	REFERENT_COUNT += 1
	setmetatable(referent, mt)

	return table.freeze(referent)
end

function Referent.none(): Referent
	local referent = {
		id = 0,
	}
	setmetatable(referent, mt)

	return table.freeze(referent)
end

function methods.IsSome(self: Referent): boolean
	return self.id ~= 0
end

function methods.IsNone(self: Referent): boolean
	return self.id == 0
end

mt.__index = methods

function mt.__tostring(self: Referent): string
	return `Referent({hex_string(self.id)})`
end

function mt.__newindex(self: Referent, new_index: unknown): never
	error(`attempted to index {self} with index '{new_index}' which is not allowed`)
end

function mt.__eq(a: Referent, b: Referent): boolean
	return a.id == b.id
end

return Referent
