local LPState = require("client.LPState")
local CloudBackground = require("client.backgrounds.CloudBackground")
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



local CLOUD_BACKGROUND = CloudBackground()

local SHOW_DESCRIPTION_AFTER = 0.5
local descriptionUpToDate = false


backgroundManager.setBackground(CLOUD_BACKGROUND)

umg.on("@update", function(dt)
    local hovered = lp.getHoveredSlot()
    if not hovered then
        descriptionUpToDate = false
        return
    end

    local time = love.timer.getTime()
    if time > hovered.time + SHOW_DESCRIPTION_AFTER then
        if not descriptionUpToDate then
            local slotEnt = hovered.entity
            local itemEnt = lp.slotToItem(slotEnt)
            lpState:getScene():setCursorDescription(itemEnt or slotEnt)
            descriptionUpToDate = true
        end
    end
end)

umg.on("lootplot:hoverChanged", function()
    descriptionUpToDate = false
    lpState:getScene():setCursorDescription(nil)
end)


state.push(lpState, 0)
musicManager.playNormalBGM()
