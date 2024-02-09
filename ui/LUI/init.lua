
local PATH = (...):gsub('%.init$', '')

local LUI = {}


LUI.Element = require(PATH .. ".ElementClass")
LUI.Scene = require(PATH .. ".Scene")


return LUI

