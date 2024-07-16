---@meta
local sound = {}
if false then _G.sound = sound end

local function dummy() end

sound.BaseSound = require("shared.BaseSound")
sound.Sound = require("shared.Sound")

return sound
