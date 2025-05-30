local types = require("@self/types")
local new = require("@self/new")
local ids = require("@self/ids")
local size = require("@self/size")

export type RobloxValue = types.RobloxValue
export type RobloxType = types.RobloxType

local RobloxType = {}

RobloxType.new = new
RobloxType.ids = ids
RobloxType.size = size

return RobloxType
