
--[[

SELECTION SERVICE:

This file handles selecting of slots,
and interacting with said slots.

]]


local util = require("shared.util")
local selection = {}

---@class lootplot.SlotAction
---@field public text string|fun():string
---@field public onClick fun()
---@field public canClick? fun():boolean
---@field public priority? number
---@field public color? string

---@class lootplot.Selected
---@field public ppos lootplot.PPos
---@field public slot lootplot.SlotEntity
---@field public time number
---@field public item lootplot.ItemEntity?
---@field public actions? lootplot.SlotAction[]

---@type lootplot.Selected?
local selected = nil


function selection.reset()
    if selected then
        umg.call("lootplot:selectionChanged", nil)
    end

    selected = nil
end


local function isButtonSlot(slotEnt)
    return slotEnt.buttonSlot
end

local function pollSelectButtons(ppos, selected)
    selected.actions = umg.ask("lootplot:pollSelectionButtons", ppos)
    table.sort(selected.actions, function(a, b)
        local pa, pb = a.priority or 0, b.priority or 0
        if pa == pb then
            return a.text < b.text
        else
            return pa < pb
        end
    end)
end

---@param slotEnt lootplot.SlotEntity
---@param dontOpenButtons boolean Don't open selection buttons?
local function selectSlot(slotEnt, dontOpenButtons)
    local ppos = lp.getPos(slotEnt)
    local itemEnt = lp.slotToItem(slotEnt)
    if not (itemEnt and ppos) then
        return
    end

    if isButtonSlot(slotEnt) then
        return
    end

    selected = {
        ppos = ppos,
        slot = slotEnt,
        time = love.timer.getTime(),
        item = lp.posToItem(ppos)
    }

    if not dontOpenButtons then
        pollSelectButtons(ppos, selected)
    end

    umg.call("lootplot:selectionChanged", selected)
end

function selection.selectSlot(slotEnt)
    selectSlot(slotEnt, false)
end

function selection.selectSlotNoButtons(slotEnt)
    selectSlot(slotEnt, true)
end

-- This handles the "Cancel" button
umg.answer("lootplot:pollSelectionButtons", function(ppos)
    return {
        text = "Cancel",
        color = "red",
        onClick = selection.reset,
        priority = math.huge
    }
end)

local function validate()
    if not selected then
        return -- nothing to validate
    end

    if (not umg.exists(selected.slot)) then
        selection.reset()
        return
    end

    local realSlot = lp.posToSlot(selected.ppos)
    if realSlot ~= selected.slot then
        selection.reset()
        return
    end

    if selected.item then
        if not umg.exists(selected.item) then
            selection.reset()
            return
        end

        local realItem = lp.posToItem(selected.ppos)
        if realItem ~= selected.item then
            selection.reset()
            return
        end
    end
end


local function deny(slotEnt)
    umg.call("lootplot:denySlotInteraction", slotEnt)
end

---@param slotEnt lootplot.SlotEntity
---@param clientId string
local function hasAccess(slotEnt, clientId)
    local itemEnt = lp.slotToItem(slotEnt)

    if itemEnt then
        return lp.canPlayerAccess(itemEnt, clientId)
    end

    return true
end



local EVICT_ARGS = {"string", "entity"}

local itemEvictedFromSlot = util.remoteBroadcastToClient("lootplot:itemEvictedFromSlot", EVICT_ARGS,
function(clientToSelect, evictedSlot)
    --[[
    QUESTION: Why dont we unicast here?
    ANSWER: Because unicast packets are received BEFORE broadcast packets.
    Which means that the slot/item positions are gonna be outdated;
    the below code ASSUMES that lp.swapItems is called before this, in order for the selection to be valid.
    ]]
    if client.getClient() == clientToSelect then
        selection.selectSlot(evictedSlot)
    end
end)


local ENT_2_ARGS = {"entity", "entity"}

local swapSlotItems = util.remoteCallToServer("lootplot:swapSlotItems", ENT_2_ARGS,
function(clientId, slotEnt1, slotEnt2)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    if lp.canSwap(slotEnt1, slotEnt2) and hasAccess(slotEnt1, clientId) and hasAccess(slotEnt2, clientId) then
        lp.swapItems(slotEnt1, slotEnt2)
        if lp.slotToItem(slotEnt1) then
            itemEvictedFromSlot(clientId, slotEnt1)
        end
    end
end)

---@param clientId string
---@param srcSlot lootplot.SlotEntity
---@param targSlot lootplot.SlotEntity
local function tryMove(clientId, srcSlot, targSlot)
    if lp.canSwap(srcSlot, targSlot) and hasAccess(srcSlot, clientId) and hasAccess(targSlot, clientId) then
        -- TODO: this event a bit bloaty/weird!!!
        -- redo/unify this when we get consumable items working.
        umg.call("lootplot:tryMoveItemsClient", srcSlot, targSlot)
        swapSlotItems(srcSlot, targSlot)
    else
        deny(srcSlot)
        deny(targSlot)
    end
end


local ENT_1 = {"entity"}

local activateOnServer = util.remoteCallToServer("lootplot:clickSlotButton", ENT_1,
function(clientId, slotEnt)
    -- An "interactable" slot in the world.
    --  for example: an in-world reroll button.
    if lp.canPlayerAccess(slotEnt, clientId) then
        -- We also should do some other checks passing in the client that clicked!
        -- Maybe we should unify this with interactable...?
        lp.tryActivateEntity(slotEnt)
    end
end)


local function click(slotEnt)
    if isButtonSlot(slotEnt) then
        activateOnServer(slotEnt)
    else
        -- else, select:
        selection.selectSlot(slotEnt)
    end
end

---@param clientId string
---@param slotEnt lootplot.SlotEntity
function selection.click(clientId, slotEnt)
    validate()
    if selected and selected.slot then
        if slotEnt ~= selected.slot then
            tryMove(clientId, selected.slot, slotEnt)
        end
        selection.reset()
    else
        click(slotEnt)
    end
end


function selection.getCurrentSelection()
    validate()
    return selected
end

if client then
    components.project("slot", "clickable")

    umg.on("clickables:entityClickedClient", function(slotEnt, button)
        if button == 1 then
            selection.click(client.getClient(), slotEnt)
        end
    end)


    ---@alias lootplot.EntityHover { entity: Entity, time: number }
    ---@type lootplot.EntityHover?
    local slotHover
    ---@type lootplot.EntityHover?
    local itemHover

    function selection.getHoveredSlot()
        if slotHover and umg.exists(slotHover.entity) then
            return slotHover
        else
            slotHover = nil
        end
    end

    function selection.getHoveredItem()
        if itemHover and umg.exists(itemHover.entity) then
            return itemHover
        else
            itemHover = nil
        end
    end

    local function changeHover()
        umg.call("lootplot:hoverChanged")
    end

    umg.on("hoverables:startHover", function(ent)
        if lp.isItemEntity(ent) then
            itemHover = {
                entity = ent,
                time = love.timer.getTime()
            }
            changeHover()
        elseif lp.isSlotEntity(ent) then
            slotHover = {
                entity = ent,
                time = love.timer.getTime()
            }
            changeHover()
        end
    end)

    umg.on("hoverables:endHover", function(ent)
        if ent == (slotHover and slotHover.entity) then
            slotHover = nil
            changeHover()
        elseif ent == (itemHover and itemHover.entity) then
            itemHover = nil
            changeHover()
        end
    end)

end




if client then
    return selection
end
