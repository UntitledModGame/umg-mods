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
    scene:setSelectedItemDescription()

    if selection then
        scene:setActionButtons(selection.actions)

        local itemEnt = lp.posToItem(selection.ppos)

        if itemEnt then
            scene:setSelectedItemDescription(itemEnt)
        end
    else
        scene:setActionButtons()
    end
end)

umg.on("@resize", function(x,y)
    lpState:resize(x,y)
end)



local CLOUD_BACKGROUND = CloudBackground()

local SHOW_DESCRIPTION_AFTER = 0.5
local selectedSlot = nil
local slotHoverTime = 0

backgroundManager.setBackground(CLOUD_BACKGROUND)



umg.on("@update", function(dt)
    if umg.exists(selectedSlot) then
        ---@cast selectedSlot Entity
        if slotHoverTime < SHOW_DESCRIPTION_AFTER then
            slotHoverTime = slotHoverTime + dt

            if slotHoverTime >= SHOW_DESCRIPTION_AFTER then
                local itemEnt = lp.slotToItem(selectedSlot)
                lpState:getScene():setCursorDescription(itemEnt or selectedSlot)
            end
        end
    end
end)

umg.on("lootplot:startHoverSlot", function(ent)
    selectedSlot = ent
    slotHoverTime = 0
end)

umg.on("lootplot:endHoverSlot", function(ent)
    selectedSlot = nil
    lpState:getScene():setCursorDescription()
end)



state.push(lpState, 0)
musicManager.playNormalBGM()
