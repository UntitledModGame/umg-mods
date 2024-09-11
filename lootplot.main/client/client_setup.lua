local LPState = require("client.LPState")
local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")
local backgroundManager = require("client.background_manager")

local musicManager = require("client.music_manager")



---@type lootplot.main.State
local lpState = LPState()



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
local CLOUD_BACKGROUND = PulsingCloudBackground({
    worldX = -W/2, worldY = -H/2,
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



state.push(lpState, 0)
musicManager.playNormalBGM()
