local sound = {}
if false then _G.sound = sound end

---@module "client.BaseSound"
sound.BaseSound = require("client.BaseSound")
---@module "client.RandomSound"
sound.RandomSound = require("client.RandomSound")
---@module "client.Sound"
sound.Sound = require("client.Sound")
---@module "client.VarianceSound"
sound.VarianceSound = require("client.VarianceSound")

umg.expose("sound", sound)
return sound
