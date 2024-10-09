local LPState = require("client.states.LPState")
local RunState = require("client.states.RunState")
local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")
local backgroundManager = require("client.background_manager")
local musicManager = require("client.music_manager")
local runManager = require("shared.run_manager")



---@type lootplot.main.State
local lpState = LPState()
---@type lootplot.main.RunState
local runState = RunState()



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
local lpStatePushed = false
local runStatePushed = false

local LP_STATE_Z_ORDER = 0


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

    if lp.main.isReady() then
        if runStatePushed then
            state.pop(runState)
            runStatePushed = false
        end

        if not lpStatePushed then
            lpStatePushed = true
            state.push(lpState, LP_STATE_Z_ORDER)
        end
    end
end)



local CONTINUE_RUN_STATE_Z_ORDER = 10


local function makeCallableOnce(f)
    local called = false

    return function(...)
        if not called then
            called = true
            return f(...)
        end
    end
end

umg.on("@load", function()
    -- let @update loop handle pushing LPState
    if not lp.main.isReady() then
        runManager.queryRun(function(host, run)
            local setupData = nil

            if host then
                if run then
                    setupData = {
                        continueRunAction = makeCallableOnce(runManager.continueRun),
                        newRunAction = makeCallableOnce(runManager.newRun)
                    }
                else
                    return runManager.newRun()
                    -- return to prevent propagation.
                end
            end

            runStatePushed = true
            runState:setup(setupData)
            state.push(runState, CONTINUE_RUN_STATE_Z_ORDER)
        end)
    end
end)

musicManager.playNormalBGM()
