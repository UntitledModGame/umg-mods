
--[[

SELECTION SERVICE:

This file handles selecting of slots,
and interacting with said slots.

]]


local util = require("shared.util")
local selection = {}


local buttonScene
if client then
    ---@type lootplot.ButtonScene
    buttonScene = require("client.ui")
end


local selectedPPos
local selectedSlot


local function reset()
    buttonScene:clear()
    selectedPPos = nil
    selectedSlot = nil
end
selection.reset = reset


local function isButtonSlot(slotEnt)
    return slotEnt.buttonSlot
end

---@param slotEnt lootplot.SlotEntity
local function selectSlot(slotEnt)
    if not lp.slotToItem(slotEnt) then
        return
    end

    if isButtonSlot(slotEnt) then
        return
    end

    selectedPPos = lp.getPos(slotEnt)
    selectedSlot = slotEnt

    if lp.slotToItem(slotEnt) then
        local buttonList = objects.Array()
        umg.call("lootplot:pollSlotButtons", selectedPPos, buttonList)
        buttonList:add(ui.elements.Button({
            onClick = reset,
            text = "Cancel"
        }))
        buttonScene:setButtons(buttonList)
    end
end
selection.selectSlot = selectSlot


local function validate()
    if not selectedPPos then
        return -- nothing to validate
    end
    if (not umg.exists(selectedSlot)) then
        reset()
    end
    local slot = lp.posToSlot(selectedPPos)
    if slot ~= selectedSlot then
        reset()
    end
end

local function canAddItem(slotEnt, itemEnt)
    -- whether or not we can ADD an item to slotEnt.
    if lp.slotToItem(slotEnt) then
        return false
    end
    return couldHoldItem(slotEnt, itemEnt)
end

local function deny(slotEnt)
    --[[
        TODO: put some juice here;
            - shake the slot...?
            - emit a BUZZ sound to imply failure...?
    ]]
    print("DENY! wot wot")
    --umg.melt("todo: make deny juice")
end


local ENT_2 = {"entity", "entity"}

local swapSlotItems = util.remoteServerCall("lootplot:swapSlotItems", ENT_2, 
function(clientId, slotEnt1, slotEnt2)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    local item1 = lp.slotToItem(slotEnt1)
    local item2 = lp.slotToItem(slotEnt2)
    if lp.canSwap(slotEnt1, slotEnt2) then
        lp.swapItems(slotEnt1, slotEnt2)
    end
end)

---@param slotEnt lootplot.SlotEntity
---@param clientId string
local function hasAccess(slotEnt, clientId)
    local itemEnt = lp.slotToItem(slotEnt)

    if itemEnt then
        return lp.canPlayerAccess(itemEnt, clientId)
    end

    return true
end

---@param clientId string
---@param srcSlot lootplot.SlotEntity
---@param targSlot lootplot.SlotEntity
local function tryMove(clientId, srcSlot, targSlot)
    if lp.canSwap(srcSlot, targSlot) and hasAccess(srcSlot, clientId) and hasAccess(targSlot, clientId) then
        swapSlotItems(srcSlot, targSlot)
    else
        deny(srcSlot)
        deny(targSlot)
    end
end



local function click(slotEnt)
    if isButtonSlot(slotEnt) then
        -- An "interactable" slot in the world.
        --  for example: an in-world reroll button.
        if lp.canActivateEntity(slotEnt) then
            -- We also should do some other checks passing in the client that clicked!
            -- Maybe we should unify this with interactable...?
            lp.activateEntity(slotEnt)
        end
    else
        -- else, select:
        selectSlot(slotEnt)
    end
end

---@param clientId string
---@param slotEnt lootplot.SlotEntity
function selection.click(clientId, slotEnt)
    validate()
    if selectedSlot then
        if slotEnt ~= selectedSlot then
            tryMove(clientId, selectedSlot, slotEnt)
        end
        reset()
    else
        click(slotEnt)
    end
end


function selection.getSelected()
    validate()
    return selectedSlot
end






if client then
    components.project("slot", "clickable")

    umg.on("clickables:entityClickedClient", function(slotEnt, button)
        if button == 1 then
            selection.click(client.getClient(), slotEnt)
        end
    end)

    local lg=love.graphics
    umg.on("rendering:drawEntity", -10, function(ent)
        if ent == selectedSlot then
            lg.push("all")
                love.graphics.setColor(1,0,0)
                love.graphics.circle("line",ent.x,ent.y,14)
            lg.pop()
        end
    end)
end




if client then
    return selection
end
