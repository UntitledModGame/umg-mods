local LoadingState = require("client.states.LoadingState")
local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")
local FunkyBackground = require("client.backgrounds.FunkyBackground")
local musicManager = require("client.music_manager")
local Z_ORDER = require("client.z_order")



local W,H = 3000,1500

require("shared.exports")

-- HACK: kinda hacky, hardcode plot offset
local minsize = math.min(lp.main.constants.WORLD_PLOT_SIZE[1], lp.main.constants.WORLD_PLOT_SIZE[2])
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2
local DEFAULT_BG_NAME = "lootplot.main:cloud_background"

lp.backgrounds.registerBackground(DEFAULT_BG_NAME, {
    name = localization.localize("Cloud Background"),
    constructor = function()
        return PulsingCloudBackground({
            worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
            worldWidth = W, worldHeight = H,
            numberOfClouds = 100
        })
    end
})

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

lp.backgrounds.setBackground(DEFAULT_BG_NAME)


state.push(LoadingState(), Z_ORDER.LOADING_STATE)
musicManager.playNormalBGM()
