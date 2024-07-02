
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


--[[
    TODO:
    Should we be exporting these functions..?
    Maybe some systems will want to know whether an item can be moved or not;
    Example:
    ITEM- if all touching items cannot move,
        gain +10 points

    For now, embrace yagni.
]]
---@param clientId string
---@param slotEnt lootplot.SlotEntity
local function canRemoveItem(clientId, slotEnt)
    -- whether or not we can REMOVE an item at ppos
    local itemEnt = lp.slotToItem(slotEnt)

    if not (itemEnt and slotEnt) then
        return false -- no item to remove!
    end

    return lp.canPlayerAccess(itemEnt, clientId) and not umg.ask("lootplot:isItemRemovalBlocked", slotEnt, itemEnt)
end

local function couldHoldItem(slotEnt, itemEnt)
    --[[
        checks whether or not a slot COULD hold the item,

        We need this check for swapping items.
        (If we use `canAddItem` when swapping items, then we will always
            get false, because theres another item in the slot.)
    ]]
    return not umg.ask("lootplot:isItemAdditionBlocked", slotEnt, itemEnt)
end

local function canAddItem(slotEnt, itemEnt)
    -- whether or not we can ADD an item to slotEnt.
    if lp.slotToItem(slotEnt) then
        return false
    end
    return couldHoldItem(slotEnt, itemEnt)
end

---@param clientId string
---@param srcSlot lootplot.SlotEntity
---@param targetSlot lootplot.SlotEntity
local function canMoveFromTo(clientId, srcSlot, targetSlot)
    local item = lp.slotToItem(srcSlot)
    if not item then
        return false
    end
    if couldHoldItem(targetSlot, item) and canRemoveItem(clientId, srcSlot) then
        return true
    end
end


local function hasItem(slotEnt)
    return lp.slotToItem(slotEnt)
end

---@param clientId string
---@param slot1 lootplot.SlotEntity
---@param slot2 lootplot.SlotEntity
local function canSwap(clientId, slot1, slot2)
    return canMoveFromTo(clientId, slot1, slot2) and canMoveFromTo(clientId, slot2, slot1)
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
    if canSwap(clientId, slotEnt1, slotEnt2) then
        lp.swapItems(item1, item2)
    end
end)

local moveSlotItem = util.remoteServerCall("lootplot:moveSlotItem", ENT_2, 
function(clientId, srcSlotEnt, targetSlotEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    local item = lp.slotToItem(srcSlotEnt)
    if item and canMoveFromTo(clientId, srcSlotEnt, targetSlotEnt) then
        assert(item.item and srcSlotEnt.slot and targetSlotEnt.slot, "?")
        lp.moveItem(item, targetSlotEnt)
    end
end)


---@param clientId string
---@param srcSlot lootplot.SlotEntity
---@param targSlot lootplot.SlotEntity
local function tryMove(clientId, srcSlot, targSlot)
    if hasItem(targSlot) then
        -- then we try to swap items
        if canSwap(clientId, srcSlot, targSlot) then
            swapSlotItems(srcSlot, targSlot)
        else
            deny(srcSlot)
            deny(targSlot)
        end
    else
        -- Else, try move slot1 item --> slot2
        if canMoveFromTo(clientId, srcSlot, targSlot) then
            assert(not hasItem(targSlot),"???") -- just to be safe lol
            moveSlotItem(srcSlot, targSlot)
        end
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
