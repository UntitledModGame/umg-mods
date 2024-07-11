
--[[

Global api helper methods.
slotGrid
]]

local ptrack = require("shared.internal.positionTracking")
local trigger = require("shared.trigger")
local selection = require("shared.selection")


local lp = {}

if client then
lp.DescriptionBox = require("client.DescriptionBox")

---@param ent Entity
---@param dbox lootplot.DescriptionBox
function lp.populateLongDescription(ent, dbox)
    umg.call("lootplot:populateDescription", ent, dbox)
end

end

if server then
local queueTc = typecheck.assert("ppos", "function")
---basic action-buffering, with 0 arguments for function.
---
---NOTE:  This function name is a bit confusing!!!
---    It doesn't actually add `func` to a queue;
---    it adds it to a LIFO stack.
---    I just think that `lp.queue` is a more sensible name than 
---        `lp.push` or `lp.buffer`
---@param ppos lootplot.PPos
---@param func fun()
function lp.queue(ppos, func)
    --[[
    ]]
    queueTc(ppos, func)
    ppos.plot:queue(func)
end

local waitTc = typecheck.assert("ppos", "number")
---@param ppos lootplot.PPos
---@param time number
function lp.wait(ppos, time)
    waitTc(ppos, time)
    ppos.plot:wait(time)
end

lp.Bufferer = require("server.Bufferer")
end



lp.PPos = require("shared.PPos")

lp.Plot = require("shared.Plot")


lp.posTc = typecheck.assert("ppos")
local entityTc = typecheck.assert("entity")


--[[
    Positioning:
]]
---@param ppos lootplot.PPos
---@return lootplot.SlotEntity?
function lp.posToSlot(ppos)
    lp.posTc(ppos)
    return ppos.plot:getSlot(ppos.slot)
end

---@param ppos lootplot.PPos
---@return lootplot.ItemEntity?
function lp.posToItem(ppos)
    lp.posTc(ppos)
    return ppos.plot:getItem(ppos.slot)
end

---@param slotEnt lootplot.SlotEntity
---@return lootplot.ItemEntity?
function lp.slotToItem(slotEnt)
    local ppos = lp.getPos(slotEnt)
    if not ppos then
        return nil
    end
    local item = lp.posToItem(ppos)
    if ppos and umg.exists(item) then
        return item
    end
end

---@param ent Entity
---@return boolean
function lp.isSlotEntity(ent)
    return not not ent.slot
end

---@param ent Entity
---@return boolean
function lp.isItemEntity(ent)
    return not not ent.item
end

---@param ent lootplot.LayerEntity
---@return lootplot.PPos?
function lp.getPos(ent)
    -- Gets the ppos of an ent
    entityTc(ent)
    local ppos = ptrack.get(ent)
    return ppos
end

---@param itemEnt lootplot.ItemEntity
function lp.itemToSlot(itemEnt)
    local ppos = lp.getPos(itemEnt)

    if ppos then
        return lp.posToSlot(ppos)
    end

    return nil
end

---@type lootplot.InitArgs?
local contextInstance = nil

---@param context lootplot.InitArgs
function lp.initialize(context)
    assert(contextInstance == nil, "lootplot already initialized")
    assert(context, "missing context")
    contextInstance = context
end


local function assertServer()
    if not server then
        umg.melt("This can only be called on client-side!", 3)
    end
end


--[[
    Money/point services:
]]
do
local modifyTc = typecheck.assert("entity", "number")

--[[
`fromEnt` is the entity that applied the point modification.
(IE a slot, or an item.)

Depending on the gamemode; this will be handled in different ways.
]]
local function modifyPoints(fromEnt, x)
    assertServer()
    local multiplier = umg.ask("lootplot:getPointMultiplier", fromEnt, x) or 1
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:pointsAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:pointsSubtracted", fromEnt, val)
    end
    local points = lp.getPoints(fromEnt)
    lp.setPoints(fromEnt, points + val)
end

---@param fromEnt Entity
---@param x number
function lp.setPoints(fromEnt, x)
    assert(contextInstance, "lootplot is not initialized")
    modifyTc(fromEnt, x)
    contextInstance:setPoints(fromEnt, x)
    umg.call("lootplot:pointsChanged", fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.addPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.subtractPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, -x)
end

---@param ent Entity
---@return number?
function lp.getPoints(ent)
    assert(contextInstance, "lootplot is not initialized")
    entityTc(ent)
    return contextInstance:getPoints(ent)
end



--[[
`fromEnt` is the entity that applied the money modification.
(So for example, it could be a slot, or an item.)
]]
local function modifyMoney(fromEnt, x)
    assertServer()
    local multiplier = umg.ask("lootplot:getMoneyMultiplier", fromEnt) or 1
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:moneyAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:moneySubtracted", fromEnt, val)
    end
    local money = lp.getMoney(fromEnt)
    lp.setMoney(fromEnt, money + val)
end

---@param fromEnt Entity
---@param x number
function lp.setMoney(fromEnt, x)
    assert(contextInstance, "lootplot is not initialized")
    contextInstance:setMoney(fromEnt, x)
    umg.call("lootplot:moneyChanged", fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.addMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.subtractMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, -x)
end

---@param ent Entity
---@return number?
function lp.getMoney(ent)
    assert(contextInstance, "lootplot is not initialized")
    entityTc(ent)
    return contextInstance:getMoney(ent)
end

end







local setSlotTc = typecheck.assert("ppos", "entity")
---@param ppos lootplot.PPos
---@param slotEnt lootplot.SlotEntity
function lp.setSlot(ppos, slotEnt)
    -- directly sets a slot.
    -- (If a previous slot existed, destroy it.)
    setSlotTc(ppos, slotEnt)
    local prevEnt = lp.posToSlot(ppos)
    if prevEnt then
        lp.destroy(prevEnt)
    end
    ppos.plot:set(ppos.slot, slotEnt)
end














local function ensureSlot(slotEnt_or_ppos)
    --[[
        Takes a slotEnt OR ppos,
        and returns a slotEnt.

        If anything is invalid, melts.
    ]]
    local ppos
    if ptrack.get(slotEnt_or_ppos) then
        -- its a slotEnt!
        ppos = lp.getPos(slotEnt_or_ppos)
    else
        ppos = slotEnt_or_ppos
    end

    local slotEnt = lp.posToSlot(ppos)
    if not slotEnt then
        umg.melt("Invalid slot-entity (or position) for slot!", 3)
    end
    return slotEnt, ppos
end


local ent2Tc = typecheck.assert("entity", "entity")

---This one needs valid slot but does not require item to be present.
---If item is not present, it acts as move.
---@param slotEnt1 lootplot.SlotEntity
---@param slotEnt2 lootplot.SlotEntity
function lp.swapItems(slotEnt1, slotEnt2)
    ent2Tc(slotEnt1, slotEnt2)

    local item1 = lp.slotToItem(slotEnt1)
    local item2 = lp.slotToItem(slotEnt2)
    local ppos1, ppos2 = lp.getPos(slotEnt1), lp.getPos(slotEnt2)
    assert(ppos1 and ppos2, "Cannot swap nil-position")

    if item1 then
        ppos1:clear(item1)
    end

    if item2 then
        ppos2:clear(item2)
    end

    if item1 then
        ppos2:set(item1)
    end

    if item2 then
        ppos1:set(item2)
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
---@param slotEnt lootplot.SlotEntity
local function canRemoveItemOrNoItem(slotEnt)
    -- whether or not we can REMOVE an item at ppos
    local itemEnt = lp.slotToItem(slotEnt)

    if itemEnt then
        return not umg.ask("lootplot:isItemRemovalBlocked", slotEnt, itemEnt)
    end

    return true
end

---@param slotEnt lootplot.SlotEntity
---@param itemEnt lootplot.ItemEntity?
---@return boolean
local function couldHoldItem(slotEnt, itemEnt)
    --[[
        checks whether or not a slot COULD hold the item,

        We need this check for swapping items.
        (If we use `canAddItem` when swapping items, then we will always
            get false, because theres another item in the slot.)
    ]]
    if itemEnt then
        return not umg.ask("lootplot:isItemAdditionBlocked", slotEnt, itemEnt)
    end

    return true
end

---@param srcSlot lootplot.SlotEntity
---@param targetSlot lootplot.SlotEntity
local function canMoveFromTo(srcSlot, targetSlot)
    return couldHoldItem(targetSlot, lp.slotToItem(srcSlot)) and canRemoveItemOrNoItem(srcSlot)
end

---@param slot1 lootplot.SlotEntity
---@param slot2 lootplot.SlotEntity
---@return boolean
function lp.canSwap(slot1, slot2)
    return canMoveFromTo(slot1, slot2) and canMoveFromTo(slot2, slot1)
end

---@param ent Entity
---@return boolean
function lp.canActivateEntity(ent)
    -- TODO: use a question bus here!
    return true
end

---@param ent Entity
function lp.forceActivateEntity(ent)
    entityTc(ent)
    if ent.onActivate then
        ent:onActivate()
    end
    umg.call("lootplot:entityActivated", ent)
end

---@param ent Entity
function lp.tryActivateEntity(ent)
    entityTc(ent)
    if lp.canActivateEntity(ent) then
        lp.forceActivateEntity(ent)
        return true
    else
        umg.call("lootplot:entityActivationBlocked", ent)
        return false
    end
end

---@param pos lootplot.PPos
function lp.activate(pos)
    lp.posTc(pos)
    local item = lp.posToItem(pos)
    if item then
        lp.tryActivateEntity(item)
    end    
    local slot = lp.posToSlot(pos)
    if slot then
        lp.tryActivateEntity(slot)
    end
end

---@param ent Entity
function lp.destroy(ent)
    entityTc(ent)
    assertServer()
    if umg.exists(ent) then
        ptrack.clear(ent)
        health.server.kill(ent)
    end
end

---@param ppos lootplot.ItemEntity
function lp.sellItem(ppos)
    -- sells the item at `ppos`
    umg.melt("nyi")
end

---@param ent lootplot.LayerEntity
---@param angle number
function lp.rotate(ent, angle)
    -- TODO.
    -- rotates `ent` by an angle.
    --  ent can be a slot OR an item
end

---@generic T: EntityClass
---@param ent T
---@return T
function lp.clone(ent)
    ---@diagnostic disable-next-line: undefined-field
    local cloned = ent:clone()
    --[[
        TODO: emit events here
    ]]
    return cloned
end


---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
---@return lootplot.ItemEntity?
function lp.trySpawnItem(ppos, itemEType)
    local slotEnt = lp.posToSlot(ppos)
    local preItem = lp.posToItem(ppos)
    if slotEnt and (not preItem) then
        return lp.forceSpawnItem(ppos, itemEType)
    end
    return nil
end

---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
---@return lootplot.ItemEntity
function lp.forceSpawnItem(ppos, itemEType)
    local itemEnt = itemEType()
    local prevItem = lp.posToItem(ppos)
    if prevItem then
        prevItem:delete()
    end
    ppos:set(itemEnt)
    umg.call("lootplot:entitySpawned", itemEnt)
    return itemEnt
end


---@param ppos lootplot.PPos
---@param slotEType fun():lootplot.SlotEntity
---@return lootplot.SlotEntity?
function lp.trySpawnSlot(ppos, slotEType)
    local preSlotEnt = lp.posToSlot(ppos)
    if not preSlotEnt then
        -- if theres no slot already, spawn:
        return lp.forceSpawnSlot(ppos, slotEType)
    end
    return nil
end

---@param ppos lootplot.PPos
---@param slotEType fun():lootplot.SlotEntity
---@return lootplot.SlotEntity
function lp.forceSpawnSlot(ppos, slotEType)
    local preSlotEnt = lp.posToSlot(ppos)
    if preSlotEnt then
        preSlotEnt:delete()
    end
    local slotEnt = slotEType()
    lp.setSlot(ppos, slotEnt)
    umg.call("lootplot:entitySpawned", slotEnt)
    return slotEnt
end





---@class lootplot.LayerEntityClass: EntityClass
---@field public layer string
---@alias lootplot.LayerEntity lootplot.LayerEntityClass|Entity

local strTabTc = typecheck.assert("string", "table")

---@class lootplot.ItemEntityClass: EntityClass
---@field public item true
---@field public layer "item"
---@field public triggers lootplot.Trigger[]
---@field public buyPrice number
---@field public pointsGenerated number
---@field public moneyGenerated number
---@field public targetShape lootplot.targets.Shape?
---@field public canItemMove boolean
---@field public canBeDestroyed boolean
---@field public canActivate boolean
---@alias lootplot.ItemEntity lootplot.ItemEntityClass|lootplot.LayerEntity|Entity

---@param name string
---@param itemType table<string, any>
function lp.defineItem(name, itemType)
    strTabTc(name, itemType)
    itemType.item = true
    itemType.layer = "item"
    itemType.baseSellPrice = itemType.baseSellPrice or 1
    itemType.baseBuyPrice = itemType.baseBuyPrice or 2
    itemType.triggers = itemType.triggers or {"PULSE"}
    itemType.hoverable = true
    itemType.hoverableDistance = 8
    umg.defineEntityType(name, itemType)
    lp.ITEM_GENERATOR:defineEntry(name)
end

---@class lootplot.SlotEntityClass: EntityClass
---@field public slot true
---@field public layer "slot"
---@field public drawDepth integer
---@field public pointsGenerated number
---@field public moneyGenerated number
---@field public canBeDestroyed boolean
---@field public canActivate boolean
---@field public canSlotPropagate boolean
---@field public buttonSlot boolean
---@field public onActivate? fun(ent:lootplot.SlotEntity)
---@field public shopLock boolean
---@field public itemSpawner generation.Query?
---@field public itemReroller generation.Query?
---@alias lootplot.SlotEntity lootplot.SlotEntityClass|lootplot.LayerEntity|Entity

---@param name string
---@param slotType table<string, any>
function lp.defineSlot(name, slotType)
    strTabTc(name, slotType)
    slotType.slot = true
    slotType.layer = "slot"
    slotType.drawDepth = -600
    slotType.triggers = slotType.triggers or {"PULSE"}
    slotType.hoverable = true
    slotType.hoverableDistance = 11
    if slotType.baseCanSlotPropagate == nil then
        slotType.baseCanSlotPropagate = true
    end
    umg.defineEntityType(name, slotType)
    lp.SLOT_GENERATOR:defineEntry(name)
end

---@param name string
function lp.defineTrigger(name)
    return trigger.defineTrigger(name)
end


---@param name string
---@param ent Entity
function lp.tryTriggerEntity(name, ent)
    if lp.canTrigger(name, ent) then
        lp.forceTriggerEntity(name, ent)
        return true
    end
    return false
end

---@param name string
---@param ent Entity
function lp.forceTriggerEntity(name, ent)
    return trigger.triggerEntity(name, ent)
end

---@param name string
---@param ent Entity
---@return boolean
function lp.canTrigger(name, ent)
    return trigger.canTrigger(name, ent)
end

---@param ent lootplot.ItemEntity|lootplot.SlotEntity
---@param clientId string
---@return boolean
function lp.canPlayerAccess(ent, clientId)
    return umg.ask("lootplot:hasPlayerAccess", ent, clientId)
end

---@return lootplot.Selected?
function lp.getCurrentSelection()
    assert(client, "client-side only")
    return selection.getSelected()
end

lp.constants = {
    WORLD_SLOT_DISTANCE = 26, -- distance slots are apart in the world.
    PIPELINE_DELAY = 0.2
}

lp.ITEM_GENERATOR = generation.Generator()
lp.SLOT_GENERATOR = generation.Generator()

umg.expose("lp", lp)

return lp

