
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



---@class lootplot.Selected
---@field public ppos lootplot.PPos
---@field public slot lootplot.SlotEntity
---@field public time number

---@type lootplot.Selected?
local selected = nil


function selection.reset()
    buttonScene:clear()

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
        umg.call("lootplot:selectionChanged", selected)

        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            local buttonList = objects.Array()
            umg.call("lootplot:pollSlotButtons", selected.ppos, buttonList)
            buttonList:add(ui.elements.Button({
                onClick = selection.reset,
                text = "Cancel"
            }))
            buttonScene:setButtons(buttonList)
        end
    end
end
selection.selectSlot = selectSlot


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
end




if client then
    return selection
end