
--[[

Global api helper methods.
slotGrid
]]

local ptrack = require("shared.internal.positionTracking")
local trigger = require("shared.trigger")
local selection = require("shared.selection")


local lp = {}

if client then

---@param ent Entity
function lp.getLongDescription(ent)
    local array = objects.Array()
    --[[
    lootplot:populateDescription event ordering:
    (ie with umg.on(ev, ORDER, func)  )
    This is where stuff should be placed:

    ORDER = -inf item name
    ORDER = -10 basic description

    ORDER = 10 trigger
    ORDER = 20 filter
    ORDER = 30 action

    ORDER = 50 misc
    ORDER = 60 important misc
    ]]
    umg.call("lootplot:populateDescription", ent, array)
    return array
end

end

---@param ent Entity
---@return string
function lp.getEntityName(ent)
    return ent.name or ent:type()
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
    ppos:getPlot():queue(func)
end

local waitTc = typecheck.assert("ppos", "number")
---@param ppos lootplot.PPos
---@param time number
function lp.wait(ppos, time)
    waitTc(ppos, time)
    ppos:getPlot():wait(time)
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
    local plot = ppos:getPlot()
    return plot:getSlot(ppos.slot)
end

---@param ppos lootplot.PPos
---@return lootplot.ItemEntity?
function lp.posToItem(ppos)
    lp.posTc(ppos)
    local plot = ppos:getPlot()
    return plot:getItem(ppos.slot)
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



local REQUIRED_CONTEXT_KEYS = {
    "getPoints",
    "getMoney",
    "getCombo",
}

---@type lootplot.InitArgs?
local contextInstance = nil

---@param context lootplot.InitArgs
function lp.initialize(context)
    assert(contextInstance == nil, "lootplot already initialized")
    assert(context, "missing context")
    for _, k in ipairs(REQUIRED_CONTEXT_KEYS)do
        assert(context[k], "Missing function in Context: " .. k)
    end
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
    local points = lp.getPoints(fromEnt)
    if points then
        local multiplier = umg.ask("lootplot:getPointMultiplier", fromEnt, x) or 1
        local val = x*multiplier
        lp.setPoints(fromEnt, points + val)
    end
end

---@param fromEnt Entity
---@param x number
function lp.setPoints(fromEnt, x)
    assert(contextInstance, "lootplot is not initialized")
    modifyTc(fromEnt, x)
    local oldVal = contextInstance:getPoints(fromEnt)
    if oldVal then
        local delta = x - oldVal
        contextInstance:setPoints(fromEnt, x)
        umg.call("lootplot:pointsChanged", fromEnt, delta, oldVal, x)
    end
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
    local money = lp.getMoney(fromEnt)
    if money then
        local multiplier = umg.ask("lootplot:getMoneyMultiplier", fromEnt) or 1
        local val = x*multiplier
        lp.setMoney(fromEnt, money + val)
    end
end

---@param fromEnt Entity
---@param x number
function lp.setMoney(fromEnt, x)
    assert(contextInstance, "lootplot is not initialized")
    local oldVal = contextInstance:getMoney(fromEnt)
    if oldVal then
        local delta = x - oldVal
        contextInstance:setMoney(fromEnt, x)
        umg.call("lootplot:moneyChanged", fromEnt, delta, oldVal, x)
    end
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


local function setCombo(fromEnt, newVal)
    assert(contextInstance, "lootplot is not initialized")
    assertServer()
    local oldVal = contextInstance:getCombo(fromEnt)
    if oldVal then
        local delta = newVal - oldVal
        umg.call("lootplot:comboChanged", fromEnt, delta, oldVal, newVal)
        contextInstance:setCombo(fromEnt, newVal)
    end
end

---@param ent Entity
---@param x? number
function lp.incrementCombo(ent, x)
    entityTc(ent)
    assert(contextInstance, "lootplot is not initialized")
    local oldVal = contextInstance:getCombo(ent)
    if oldVal then
        setCombo(ent, math.max(0, oldVal + (x or 1)))
    end
end

---@param ent Entity
function lp.resetCombo(ent)
    entityTc(ent)
    assert(contextInstance, "lootplot is not initialized")
    setCombo(ent, 0)
end

---@param ent Entity
---@return number?
function lp.getCombo(ent)
    entityTc(ent)
    assert(contextInstance, "lootplot is not initialized")
    return contextInstance:getCombo(ent)
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
    ppos:getPlot():set(ppos.slot, slotEnt)
end













local ent2Tc = typecheck.assert("entity", "entity")

---This one needs valid slot but does not require item to be present.
---If item is not present, it acts as move.
---@param slotEnt1 lootplot.SlotEntity
---@param slotEnt2 lootplot.SlotEntity
function lp.swapItems(slotEnt1, slotEnt2)
    ent2Tc(slotEnt1, slotEnt2)
    assertServer()

    if slotEnt1 == slotEnt2 then
        return -- short-circuit
    end

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
        umg.call("lootplot:itemMoved", item1, ppos1, ppos2)
    end

    if item2 then
        ppos1:set(item2)
        umg.call("lootplot:itemMoved", item2, ppos2, ppos1)
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
    return not umg.ask("lootplot:isActivationBlocked", ent)
end

---@param ent Entity
function lp.forceActivateEntity(ent)
    entityTc(ent)
    ent.activationCount = (ent.activationCount or 0) + 1
    ent.totalActivationCount = (ent.totalActivationCount or 0) + 1
    if ent.onActivate then
        ent:onActivate()
    end
    umg.call("lootplot:entityActivated", ent)
end

---@param ent Entity
---@return boolean
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

--- @param ent Entity
--- Resets an entity (ie. resets activationCount)
function lp.reset(ent)
    ent.activationCount = 0
    lp.tryTriggerEntity("RESET", ent)
    umg.call("lootplot:entityReset", ent)
end

---@param ent Entity
function lp.destroy(ent)
    entityTc(ent)
    assertServer()
    if umg.exists(ent) then
        lp.tryTriggerEntity("DESTROY", ent)
        umg.call("lootplot:entityDestroyed", ent)
        ptrack.clear(ent)
        ent:delete()
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


local function ensureDynamicProperties(ent)
    assertServer()
    if not ent:isRegularComponent("lootplotProperties") then
        ent.lootplotProperties = {
            multipliers = {--[[
                [prop] = {....}
            ]]},
            modifiers = {--[[
                [prop] = {....}
            ]]}
        }
    end
end

local function append(tabl, prop, x, operation)
    if not tabl[prop] then
        tabl[prop] = x
    else
        tabl[prop] = operation(tabl[prop], x)
    end
end

---@param ent Entity
---@param property string
---@param amount number
---@param srcEnt_or_nil Entity? entity that invoked the buff (maybe nil)
function lp.modifierBuff(ent, property, amount, srcEnt_or_nil)
    -- Permanently buffs an entity by adding a flat modifier
    ensureDynamicProperties(ent)
    append(ent.lootplotProperties.modifiers, property, amount, reducers.ADD)
    umg.call("lootplot:entityBuffed", property, srcEnt_or_nil)
end

---@param ent Entity
---@param property string
---@param amount number
---@param srcEnt_or_nil Entity? entity that invoked the buff (maybe nil)
function lp.multiplierBuff(ent, property, amount, srcEnt_or_nil)
    -- Permanently buffs an entity with a multiplier
    ensureDynamicProperties(ent)
    append(ent.lootplotProperties.multipliers, property, amount, reducers.MULTIPLY)
    umg.call("lootplot:entityBuffed", property, srcEnt_or_nil)
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
---@return lootplot.ItemEntity?
function lp.forceSpawnItem(ppos, itemEType)
    local itemEnt = itemEType()
    local prevItem = lp.posToItem(ppos)
    if prevItem then
        prevItem:delete()
    end
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt and couldHoldItem(slotEnt, itemEnt) then
        ppos:set(itemEnt)
        umg.call("lootplot:entitySpawned", itemEnt)
        return itemEnt
    else
        -- delete the item: it doesnt fit in slot.
        -- (The reason we needed to create item is because 
        --   we needed to do `couldHoldItem` check)
        itemEnt:delete()
    end
    return nil
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


local traits = require("shared.traits")
lp.addTrait = traits.addTrait
lp.removeTrait = traits.removeTrait
lp.hasTrait = traits.hasTrait
lp.defineTrait = traits.defineTrait
lp.getTraitDisplayName = traits.getDisplayName


local DEFAULT_PROPS = {
    "pointsGenerated", 
    "moneyGenerated", 
    "maxActivations"
}

local function giveCommonComponents(etype)
    for _, prop in ipairs(DEFAULT_PROPS) do
        local base = properties.getBase(prop)
        assert(base,"?")
        -- ensure base exists:
        etype[base] = etype[base] or properties.getDefault(prop)
    end
end


local function getChance(etype)
    return umg.ask("lootplot:getEntityTypeSpawnChance", etype) or 1
end


local function keys(sset)
    if not sset then
        return {}
    end
    local ks = {}
    for _, val in ipairs(sset) do
        ks[val] = true
    end
    return ks
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
---@field public targetShape lootplot.targets.ShapeData?
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
    itemType.hitboxDistance = itemType.hitboxDistance or 8
    itemType.hoverable = true
    giveCommonComponents(itemType)
    umg.defineEntityType(name, itemType)
    lp.ITEM_GENERATOR:defineEntry(name, {
        defaultChance = getChance(itemType),
        traits = keys(itemType.baseTraits)
    })
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

local DEFAULT_SLOT_HITBOX_AREA = {width = 22, height = 22, ox = 0, oy = 0}

---@param name string
---@param slotType table<string, any>
function lp.defineSlot(name, slotType)
    strTabTc(name, slotType)
    slotType.slot = true
    slotType.layer = "slot"
    slotType.drawDepth = -600
    slotType.triggers = slotType.triggers or {"PULSE"}
    slotType.hitboxArea = slotType.hitboxArea or DEFAULT_SLOT_HITBOX_AREA
    slotType.hoverable = true
    if slotType.baseCanSlotPropagate == nil then
        slotType.baseCanSlotPropagate = true
    end
    giveCommonComponents(slotType)
    umg.defineEntityType(name, slotType)
    lp.SLOT_GENERATOR:defineEntry(name, {
        defaultChance = getChance(slotType),
        traits = keys(slotType.baseTraits)
    })
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

