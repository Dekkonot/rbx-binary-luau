local decode = require("@self/decode")
local encode = require("@self/encode")

local rbx_binary = {}

rbx_binary.decode = decode
rbx_binary.encode = encode

return rbx_binary
