
--[[

SELECTION SERVICE:

This file handles selecting of slots,
and interacting with said slots.

]]


local util = require("shared.util")
local selection = {}

---@class lootplot.SlotAction
---@field public text string|{format:string,variables?:table<string,any>}
---@field public onClick fun()
---@field public onDraw? fun(x:number,y:number,w:number,h:number)
---@field public priority? number
---@field public color? objects.Color

---@class lootplot.Selected
---@field public ppos lootplot.PPos
---@field public slot lootplot.SlotEntity
---@field public time number
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

---@param slotEnt lootplot.SlotEntity
local function selectSlot(slotEnt)
    if not lp.slotToItem(slotEnt) then
        return
    end

    if isButtonSlot(slotEnt) then
        return
    end

    local ppos = lp.getPos(slotEnt)

    if ppos then
        selected = {
            ppos = ppos,
            slot = slotEnt,
            time = love.timer.getTime()
        }

        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            selected.actions = umg.ask("lootplot:pollSlotButtons", ppos)
            table.sort(selected.actions, function(a, b)
                local pa, pb = a.priority or 0, b.priority or 0
                if pa == pb then
                    return a.text < b.text
                else
                    return pa < pb
                end
            end)
        end

        umg.call("lootplot:selectionChanged", selected)
    end
end
selection.selectSlot = selectSlot

-- This handles the "Cancel" button
umg.answer("lootplot:pollSlotButtons", function(ppos)
    return {
        text = "Cancel",
        color = objects.Color.RED,
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
    end

    local slot = lp.posToSlot(selected.ppos)
    if slot ~= selected.slot then
        selection.reset()
    end
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


local swapSlotItems = util.remoteServerCall("lootplot:swapSlotItems", ENT_2, 
function(clientId, slotEnt1, slotEnt2)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    local item1 = lp.slotToItem(slotEnt1)
    local item2 = lp.slotToItem(slotEnt2)
    if lp.canSwap(slotEnt1, slotEnt2) and lp.canPlayerAccess(slotEnt1, clientId) and lp.canPlayerAccess(slotEnt2, clientId) then
        lp.swapItems(slotEnt1, slotEnt2)
    end
end)

local ENT_1 = {"entity"}

local activateOnServer = util.remoteServerCall("lootplot:clickSlotButton", ENT_1,
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
        selectSlot(slotEnt)
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


function selection.getSelected()
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

    local lg=love.graphics

    umg.on("rendering:drawEntity", -10, function(ent)
        if selected and ent == selected.slot then
            lg.push("all")
                lg.setColor(1,0,0)
                lg.circle("line",ent.x,ent.y,14)
            lg.pop()
        end
    end)

    local hoveredSlot, hoveredItem

    umg.on("hoverables:startHover", function(ent)
        if lp.isItemEntity(ent) then
            if hoveredItem then
                umg.call("lootplot:endHoverItem", hoveredItem)
            end

            hoveredItem = ent
            umg.call("lootplot:startHoverItem", ent)
        elseif lp.isSlotEntity(ent) then
            if hoveredSlot then
                umg.call("lootplot:endHoverSlot", hoveredSlot)
            end

            hoveredSlot = ent
            umg.call("lootplot:startHoverSlot", ent)
        end
    end)

    umg.on("hoverables:endHover", function(ent)
        if ent == hoveredItem then
            hoveredItem = nil
            umg.call("lootplot:endHoverItem", ent)
        elseif ent == hoveredSlot then
            hoveredSlot = nil
            umg.call("lootplot:endHoverSlot", ent)
        end
    end)
end




if client then
    return selection
end
