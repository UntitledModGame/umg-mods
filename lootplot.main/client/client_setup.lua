local LoadingState = require("client.states.LoadingState")
local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")
local backgroundManager = require("client.background_manager")
local musicManager = require("client.music_manager")




local W,H = 3000,1500

require("shared.exports")

-- HACK: kinda hacky, hardcode plot offset
local DELTA = (lp.main.constants.WORLD_PLOT_SIZE * lp.constants.WORLD_SLOT_DISTANCE) / 2

local CLOUD_BACKGROUND = PulsingCloudBackground({
    worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
    worldWidth = W, worldHeight = H,
    numberOfClouds = 100
})


backgroundManager.setBackground(CLOUD_BACKGROUND)


state.push(LoadingState(), 0)
musicManager.playNormalBGM()
