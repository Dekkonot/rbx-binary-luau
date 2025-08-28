local types = require("@self/types")
local new = require("@self/new")
local brickcolor = require("@self/brickcolor")
local ids = require("@self/ids")
local font = require("@self/font")
local size = require("@self/size")

export type RobloxValue = types.RobloxValue
export type RobloxType = types.RobloxType

local RobloxType = {}

RobloxType.new = new
RobloxType.ids = ids
RobloxType.size = size
RobloxType.brickcolor = brickcolor
RobloxType.font = font

return RobloxType
