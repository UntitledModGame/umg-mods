local LoadingState = require("client.states.LoadingState")
local musicManager = require("client.music_manager")
local Z_ORDER = require("client.z_order")

require("shared.exports")


state.push(LoadingState(), Z_ORDER.LOADING_STATE)
musicManager.playNormalBGM()
