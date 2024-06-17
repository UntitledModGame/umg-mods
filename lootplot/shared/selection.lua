
--[[

SELECTION SERVICE:

This file handles selecting of slots,
and interacting with said slots.

]]

local questions = require("shared.questions")


local selection = {}





local selectedPPos
local selectedSlot


local function reset()
    selectedPPos = nil
    selectedSlot = nil
end


local function selectSlot(slotEnt)
    selectedPPos = lp.getPos(slotEnt)
    selectedSlot = slotEnt
end


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


local function isInteractable(slotEnt)
    return false -- just for now.
end


local function canMoveFromTo(srcSlot, targetSlot)
    local item = lp.slotToItem(srcSlot)
    if not item then
        return false
    end
    if questions.couldHoldItem(targetSlot, item) and questions.canRemoveItem(srcSlot) then
        return true
    end
end


local function hasItem(slotEnt)
    return lp.slotToItem(slotEnt)
end


local function canSwap(slot1, slot2)
    return canMoveFromTo(slot1, slot2) and canMoveFromTo(slot2, slot1)
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




local function removeServerCall(name, args, func)
    umg.definePacket(name, {
        typelist = args
    })

    if server then
        server.on(name, func)
    end

    local function call(...)
        assert(client,"?")
        client.send(name, ...)
    end
    return call
end


local ENT_2 = {"entity", "entity"}

local swapSlotItems = removeServerCall("lootplot:swapSlotItems", ENT_2, 
function(clientId, slotEnt1, slotEnt2)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    local item1 = lp.slotToItem(slotEnt1)
    local item2 = lp.slotToItem(slotEnt2)
    lp.swapItems(item1, item2)
end)

local moveSlotItem = removeServerCall("lootplot:moveSlotItem", ENT_2, 
function(clientId, srcSlotEnt, targetSlotEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    local item = lp.slotToItem(srcSlotEnt)
    if item then
        lp.moveItem(item, targetSlotEnt)
    end
end)





local function tryMove(srcSlot, targSlot)
    if hasItem(targSlot) then
        -- then we try to swap items
        if canSwap(srcSlot, targSlot) then
            swapSlotItems(srcSlot, targSlot)
        else
            deny(srcSlot)
            deny(targSlot)
        end
    else
        -- Else, try move slot1 item --> slot2
        if canMoveFromTo(srcSlot, targSlot) then
            assert(not hasItem(targSlot),"???") -- just to be safe lol
            moveSlotItem(srcSlot, targSlot)
        end
    end
end



local function click(slotEnt)
    if isInteractable(slotEnt) then
        -- An "interactable" slot in the world.
        --  for example: an in-world reroll button.
    else
        -- else, select:
        selectSlot(slotEnt)
    end
end


function selection.click(slotEnt)
    validate()
    if selectedSlot then
        if slotEnt ~= selectedSlot then
            tryMove(selectedSlot, slotEnt)
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

    umg.on("clickables:entityClickedClient", function(slotEnt, clientId)
        selection.click(slotEnt)
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





return selection
