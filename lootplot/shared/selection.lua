
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
---@field public color? objects.Color

---@class lootplot.Selected
---@field public ppos lootplot.PPos
---@field public slot lootplot.SlotEntity?
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


---@param ppos lootplot.PPos
local function getButtonSlot(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt and slotEnt.buttonSlot then
        return slotEnt
    end

    return nil
end

local function collectSelectionButtons(ppos, selected)
    local array = objects.Array()
    umg.call("lootplot:populateSelectionButtons", array, ppos)
    selected.actions = array
    table.sort(selected.actions, function(a, b)
        local pa, pb = a.priority or 0, b.priority or 0
        return pa < pb
    end)
end

---@param ppos lootplot.PPos
---@param dontOpenButtons boolean Don't open selection buttons?
local function selectPosition(ppos, dontOpenButtons)
    local itemEnt = lp.posToItem(ppos)
    if not itemEnt then
        return
    end

    if getButtonSlot(ppos) then
        return
    end

    selected = {
        ppos = ppos,
        slot = lp.posToSlot(ppos),
        time = love.timer.getTime(),
        item = itemEnt
    }

    if not dontOpenButtons then
        collectSelectionButtons(ppos, selected)
    end

    umg.call("lootplot:selectionChanged", selected)
end

---@param ppos lootplot.PPos
function selection.select(ppos)
    selectPosition(ppos, false)
end

---@param ppos lootplot.PPos
function selection.selectNoButtons(ppos)
    selectPosition(ppos, true)
end

-- This handles the "Cancel" button
umg.on("lootplot:populateSelectionButtons", function(arr, ppos)
    arr:add({
        text = "Cancel",
        color = objects.Color(0.66,0.2,0.27),
        onClick = selection.reset,
        priority = math.huge
    })
end)

local function validate()
    if not selected then
        return -- nothing to validate
    end

    if selected.slot then
        local realSlot = lp.posToSlot(selected.ppos)
        if realSlot ~= selected.slot then
            selection.reset()
            return
        end
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


local function deny(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt then
        umg.call("lootplot:denySlotInteraction", slotEnt)
    end
end

---@param ppos lootplot.PPos
---@param clientId string
local function hasAccess(ppos, clientId)
    local itemEnt = lp.posToItem(ppos)

    if itemEnt then
        return lp.canPlayerAccess(itemEnt, clientId)
    end

    return true
end



local EVICT_ARGS = {"string", "entity", "number"}

local selectItemImmediately = util.remoteBroadcastToClient("lootplot:selectItemImmediately", EVICT_ARGS,
function(clientToSelect, plotEnt, index)
    --[[
    QUESTION: Why dont we unicast here?
    ANSWER: Coz unicast packets are received BEFORE broadcast packets.
    Which means the slot/item positions are gonna be outdated.
    this func ASSUMES that lp.swapItems is called prior, so we can make a valid selection.
    ]]
    if client.getClient() == clientToSelect then
        local ppos = plotEnt.plot:getPPosFromSlotIndex(index)
        selection.select(ppos)
    end
end)


local ENT_1_NUMBER_2 = {"entity", "number", "number"}

local swapSlotItems = util.remoteCallToServer("lootplot:swapSlotItems", ENT_1_NUMBER_2,
function(clientId, plotEnt, pposIndex1, pposIndex2)
    ---@type lootplot.Plot
    local plot = plotEnt.plot
    local ppos1 = plot:getPPosFromSlotIndex(pposIndex1)
    local ppos2 = plot:getPPosFromSlotIndex(pposIndex2)

    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    if lp.canSwap(ppos1, ppos2) and hasAccess(ppos1, clientId) and hasAccess(ppos2, clientId) then
        lp.swapItems(ppos1, ppos2)
        if lp.posToItem(ppos1) then
            -- When we swap items, we automatically select the target item.
            -- (GREAT FOR UX!!!)
            -- (this needs to be a packet, because of latency/async reasons.)
            selectItemImmediately(clientId, plotEnt, pposIndex1)
        end
    end
end)

---@param clientId string
---@param srcPPos lootplot.PPos
---@param targPPos lootplot.PPos
local function tryMove(clientId, srcPPos, targPPos)
    local plot = srcPPos:getPlot()
    assert(targPPos:getPlot() == plot) -- this is fails, we have big problem

    if lp.canSwap(srcPPos, targPPos) and hasAccess(srcPPos, clientId) and hasAccess(targPPos, clientId) then
        -- TODO: this event a bit bloaty/weird!!!
        -- redo/unify this when we get consumable items working.
        umg.call("lootplot:tryMoveItemsClient", srcPPos, targPPos)
        swapSlotItems(plot:getOwnerEntity(), srcPPos:getSlotIndex(), targPPos:getSlotIndex())
    else
        deny(srcPPos)
        deny(targPPos)
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


local ENT_2 = {"entity", "entity"}
local combineOnServer = util.remoteCallToServer("lootplot:clientTryCombineItems", ENT_2,
function(clientId, combineItem, targItem)
    if lp.canPlayerAccess(combineItem, clientId) and lp.canPlayerAccess(targItem, clientId) then
        lp.tryCombineItems(combineItem, targItem)
    end
end)


---@param ppos lootplot.PPos
local function canCombineSelected(ppos)
    local targItem = lp.posToItem(ppos)
    if not targItem then
        return false
    end
    local sel = selection.getCurrentSelection()
    if sel and sel.item then
        return lp.canCombineItems(sel.item, targItem)
    end
    return false
end


---@param ppos lootplot.PPos
local function tryCombineSelected(ppos)
    if canCombineSelected(ppos) then
        local targItem = lp.posToItem(ppos)
        local sel = assert(selection.getCurrentSelection())
        combineOnServer(assert(sel.item), targItem)
    end
end


---@param ppos lootplot.PPos
local function clickEmpty(ppos)
    local slotEnt = getButtonSlot(ppos)

    if slotEnt then
        activateOnServer(slotEnt)
    else
        -- else, select:
        selection.select(ppos)
    end
end

---@param clientId string
---@param ppos lootplot.PPos
function selection.click(clientId, ppos)
    validate()
    if selected then
        print(selected.ppos)
    else
        print("no selection.")
    end
    if selected then
        if ppos ~= selected.ppos then
            -- print("HERE::0")
            if canCombineSelected(ppos) then
                tryCombineSelected(ppos)
            else
                -- print("HERE:1")
                tryMove(clientId, selected.ppos, ppos)
            end
        end
        selection.reset()
    else
        clickEmpty(ppos)
    end
end


---@return (lootplot.Selected)?
function selection.getCurrentSelection()
    validate()
    return selected
end

if client then
    components.project("slot", "clickable")

    local listener = input.InputListener()

    function selection.getListener()
        return listener
    end

    local plotEnts = umg.group("plot", "x", "y")

    listener:onPressed("input:CLICK_PRIMARY", function(listener, controlEnum)
        local cam = camera.get()
        local worldX,worldY = cam:toWorldCoords(input.getPointerPosition())
        local dim = cam:getDimension()
        for _,ent in ipairs(plotEnts) do
            if spatial.getDimension(ent) == dim then
                -- good enough. lets try this.
                local plot = ent.plot
                ---@cast plot lootplot.Plot
                local ppos = plot:getClosestPPos(worldX,worldY)
                selection.click(client.getClient(), ppos)
                return
            end
        end
    end)

    --[[
    umg.on("clickables:entityClickedClient", function(ent, button)
        if button == 1 then
            print("clicked", ent)
            local ppos = lp.getPos(ent)

            if ppos then
                selection.click(client.getClient(), ppos)
            end
        end
    end)
    ]]

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
