local LPState = require("client.states.LPState")
local RunState = require("client.states.RunState")
local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")
local backgroundManager = require("client.background_manager")
local musicManager = require("client.music_manager")
local runManager = require("shared.run_manager")



---@type lootplot.main.State
local lpState = LPState()
---@type lootplot.main.RunState|nil
local runState = nil



local winLose = require("shared.win_lose")
winLose.setEndGameCallback(function(win)
    lpState:getScene():showEndGameDialog(win)
end)



-- Handles action button selection
---@param selection lootplot.Selected
umg.on("lootplot:selectionChanged", function(selection)
    local scene = lpState:getScene()
    scene:setSelection(selection)
end)


umg.on("@resize", function(x,y)
    lpState:resize(x,y)
end)




local W,H = 3000,1500

require("shared.exports")

-- HACK: kinda hacky, hardcode plot offset
local DELTA = (lp.main.constants.WORLD_PLOT_SIZE * lp.constants.WORLD_SLOT_DISTANCE) / 2

local CLOUD_BACKGROUND = PulsingCloudBackground({
    worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
    worldWidth = W, worldHeight = H,
    numberOfClouds = 100
})

local lastHoveredEntity = nil


backgroundManager.setBackground(CLOUD_BACKGROUND)

umg.on("@update", function(dt)
    local hovered = lp.getHoveredSlot()
    local hoveredEntity = nil

    if hovered then
        local slotEnt = hovered.entity
        local itemEnt = lp.slotToItem(slotEnt)
        hoveredEntity = itemEnt or slotEnt
    end

    if hoveredEntity ~= lastHoveredEntity then
        lpState:getScene():setCursorDescription(hoveredEntity)
        lastHoveredEntity = hoveredEntity
    end
end)



local lpStatePushed = false
local runInfoChecked = false

local LP_STATE_Z_ORDER = 0
local CONTINUE_RUN_STATE_Z_ORDER = 10

umg.on("@tick", function()
    if lp.main.isReady() then
        if runState then
            state.pop(runState)
            runState = nil
        end

        if not lpStatePushed then
            lpStatePushed = true
            state.push(lpState, LP_STATE_Z_ORDER)
        end
    elseif runManager.hasReceivedInfo() and not runInfoChecked then
        runInfoChecked = true
        local runInfo = runManager.getSavedRun()

        if runInfo then
            runState = RunState({
                runInfo = runInfo,
                callback = runManager.startRun
            })
            state.push(runState, CONTINUE_RUN_STATE_Z_ORDER)
        else
            runManager.startRun(false)
        end
    end
end)

musicManager.playNormalBGM()
