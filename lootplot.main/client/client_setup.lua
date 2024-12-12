local LoadingState = require("client.states.LoadingState")
local FunkyBackground = require("client.backgrounds.FunkyBackground")
local musicManager = require("client.music_manager")
local Z_ORDER = require("client.z_order")


require("shared.exports")

--[[
local BACKGROUND = FunkyBackground({
    worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
    worldWidth = W, worldHeight = H,

    nodeDistance = 25,
    nodeHueShift = 25,
    nodeValueShfit = 0,
    nodeSaturationShift = 0,
    noisePeriod = 200,
    color = objects.Color(0.62,0.2,0.93),
    noiseSpeed = 0.1,
})
]]


state.push(LoadingState(), Z_ORDER.LOADING_STATE)
musicManager.playNormalBGM()
