
--[[

Global api helper methods.
slotGrid
]]

local ptrack = require("shared.internal.positionTracking")
local trigger = require("shared.trigger")
local selection = require("shared.selection")


---@alias lootplot._BufferedEtype {name:string, entityType:table, generator:generation.Generator}

-- We need to buffer-define entity-types, 
-- so future mods have opportunities to modify them
local bufferedEntityTypes = objects.Array()


local lp = {}

if client then

---Availability: **Client**
---@param ent Entity
---@return (string | function)[]
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

---Availability: Client and Server
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
---
---Availability: **Server**
---@param ppos lootplot.PPos
---@param func fun()
function lp.queue(ppos, func)
    queueTc(ppos, func)
    ppos:getPlot():queue(func)
end


local queueWithEntityTc = typecheck.assert("entity", "function")

---Availability: **Server**
---@param ent Entity
---@param func fun(ent:Entity)
function lp.queueWithEntity(ent, func)
    queueWithEntityTc(ent, func)
    local ppos = lp.getPos(ent)
    if ppos then
        lp.queue(ppos, function()
            if umg.exists(ent) then
                func(ent)
            end
        end)
    end
end

local waitTc = typecheck.assert("ppos", "number")

---Availability: **Server**
---@param ppos lootplot.PPos
---@param time number
function lp.wait(ppos, time)
    waitTc(ppos, time)
    ppos:getPlot():wait(time)
end

lp.Bufferer = require("server.Bufferer")
end


---Availability: Client and Server
lp.PPos = require("shared.PPos")
---Availability: Client and Server
lp.Plot = require("shared.Plot")


lp.posTc = typecheck.assert("ppos")
local entityTc = typecheck.assert("entity")


--[[
    Positioning:
]]
---Availability: Client and Server
---@param ppos lootplot.PPos
---@return lootplot.SlotEntity?
function lp.posToSlot(ppos)
    lp.posTc(ppos)
    local plot = ppos:getPlot()
    local x,y = plot:indexToCoords(ppos:getSlotIndex())
    return plot:getSlot(x,y)
end

---Availability: Client and Server
---@param ppos lootplot.PPos
---@return lootplot.ItemEntity?
function lp.posToItem(ppos)
    lp.posTc(ppos)
    local plot = ppos:getPlot()
    local x,y = plot:indexToCoords(ppos:getSlotIndex())
    return plot:getItem(x,y)
end

---Availability: Client and Server
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

---Availability: Client and Server
---@param ent Entity
---@return boolean
function lp.isSlotEntity(ent)
    return not not ent.slot
end

---Availability: Client and Server
---@param ent Entity
---@return boolean
function lp.isItemEntity(ent)
    return not not ent.item
end

---Availability: Client and Server
---@param ent lootplot.LayerEntity
---@return lootplot.PPos?
function lp.getPos(ent)
    -- Gets the ppos of an ent
    entityTc(ent)
    local ppos = ptrack.get(ent)
    return ppos
end



lp.CONVERSIONS = {
    ITEM = "ITEM",
    SLOT = "SLOT",
    ITEM_OR_SLOT = "ITEM_OR_SLOT", -- checks item first, then slot
    SLOT_OR_ITEM = "SLOT_OR_ITEM", -- checks slot first, then item
    NO_ITEM = "NO_ITEM", -- ppos with no item
    NO_SLOT = "NO_SLOT", -- ppos with no slot
}

---@alias lootplot.CONVERSION_TYPE "ITEM"|"SLOT"|"NO_SLOT"|"NO_ITEM"|"ITEM_OR_SLOT"|"SLOT_OR_ITEM"

--- Returns a boolean, true iff the ppos is valid w.r.t the conversion type.
--- The second return value is the entity (if any) that was converted.
---@param conversionType lootplot.CONVERSION_TYPE?
---@param ppos lootplot.PPos
---@return boolean, lootplot.LayerEntity?
function lp.tryConvert(ppos, conversionType)
    if conversionType == "ITEM" then
        local item = lp.posToItem(ppos)
        return (not not item), item
    elseif conversionType == "SLOT" then
        local slot = lp.posToSlot(ppos)
        return (not not slot), slot
    elseif conversionType == "NO_ITEM" then
        return (not lp.posToItem(ppos))
    elseif conversionType == "NO_SLOT" then
        return not lp.posToSlot(ppos)
    elseif conversionType == "ITEM_OR_SLOT" then
        local item = lp.posToItem(ppos)
        if item then
            return true, item
        end
        local slot = lp.posToSlot(ppos)
        if slot then
            return true, slot
        end
    elseif conversionType == "SLOT_OR_ITEM" then
        local slot = lp.posToSlot(ppos)
        if slot then
            return true, slot
        end
        local item = lp.posToItem(ppos)
        if item then
            return true, item
        end
    end
    return false
end



---Availability: Client and Server
---@param itemEnt lootplot.ItemEntity
---@return lootplot.SlotEntity?
function lp.itemToSlot(itemEnt)
    local ppos = lp.getPos(itemEnt)

    if ppos then
        return lp.posToSlot(ppos)
    end

    return nil
end



local attributes = require("shared.attributes")

lp.getAttribute = attributes.getAttribute
lp.setAttribute = attributes.setAttribute
lp.getAllAttributes = attributes.getAllAttributes
lp.modifyAttribute = attributes.modifyAttribute
lp.isValidAttribute = attributes.isValidAttribute

lp.defineAttribute = attributes.defineAttribute

lp.defineAttribute("MONEY")
lp.defineAttribute("POINTS")


-- COMBO = number of successive activations without interruption.
lp.defineAttribute("COMBO")

-- "LEVEL" is a general difficulty indicator.
-- higher level = higher difficulty.
lp.defineAttribute("LEVEL")




local initArgs = nil

---Initialize core lootplot game.
---
---Availability: Client and Server
---@param args lootplot.AttributeInitArgs
function lp.initialize(args)
    assert(initArgs == nil, "lootplot already initialized")
    assert(args, "missing context")
    initArgs = args
    attributes.initialize(args)
    assert(lp.FALLBACK_NULL_ITEM, "Must provide fallback item")
    assert(lp.FALLBACK_NULL_SLOT, "Must provide fallback slot")
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

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.setPoints(fromEnt, x)
    lp.setAttribute("POINTS", fromEnt, x)
end

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.addPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.modifyAttribute("POINTS", fromEnt, x)
end


---Availability: Client and Server
---@param ent Entity
---@return number?
function lp.getPoints(ent)
    entityTc(ent)
    return lp.getAttribute("POINTS", ent)
end




---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.setMoney(fromEnt, x)
    lp.setAttribute("MONEY", fromEnt, x)
end

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.addMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.modifyAttribute("MONEY", fromEnt, x)
end

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.subtractMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.modifyAttribute("MONEY", fromEnt, -x)
end

---Availability: Client and Server
---@param ent Entity
---@return number?
function lp.getMoney(ent)
    entityTc(ent)
    return lp.getAttribute("MONEY", ent)
end


function lp.setLevel(ent, x)
    modifyTc(ent, x)
    lp.setAttribute("LEVEL", ent, x)
end
function lp.getLevel(ent)
    entityTc(ent)
    return lp.getAttribute("LEVEL", ent)
end



---Availability: **Server**
---@param ent Entity
---@param x? number
function lp.incrementCombo(ent, x)
    entityTc(ent)
    lp.modifyAttribute("COMBO", ent, x or 1)
end

---Availability: **Server**
---@param ent Entity
function lp.resetCombo(ent)
    assert(initArgs, "lootplot is not initialized")
    lp.setAttribute("COMBO", ent, 0)
end

---Availability: Client and Server
---@param ent Entity
---@return number
function lp.getCombo(ent)
    entityTc(ent)
    return lp.getAttribute("COMBO", ent)
end

end







local setSlotTc = typecheck.assert("ppos", "entity")

---Availability: **Server**
---@param ppos lootplot.PPos
---@param slotEnt lootplot.SlotEntity
function lp.setSlot(ppos, slotEnt)
    -- directly sets a slot.
    -- (If a previous slot existed, destroy it.)
    assert(slotEnt.slot, "Must be a slot entity")
    setSlotTc(ppos, slotEnt)
    local prevEnt = lp.posToSlot(ppos)
    if prevEnt then
        prevEnt:delete()
    end
    ppos:set(slotEnt)
end




local ppos2Tc = typecheck.assert("ppos", "ppos")

---This one needs valid slot but does not require item to be present.
---If item is not present, it acts as move.
---
---Availability: **Server**
---@param ppos1 lootplot.PPos
---@param ppos2 lootplot.PPos
function lp.swapItems(ppos1, ppos2)
    assertServer()
    ppos2Tc(ppos1, ppos2)

    if ppos1 == ppos2 then
        return -- short-circuit
    end

    if not lp.canSwapItems(ppos1, ppos2) then
        return
    end

    local item1 = lp.posToItem(ppos1)
    local item2 = lp.posToItem(ppos2)

    if not item1 and not item2 then
        return -- short circuit
    end

    if item1 then
        ppos1:clear(item1.layer)
    end

    if item2 then
        ppos2:clear(item2.layer)
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
---@param slotEnt lootplot.SlotEntity?
local function canRemoveItemOrNoItem(slotEnt)
    if not slotEnt then
        return true
    end

    -- whether or not we can REMOVE an item at ppos
    local itemEnt = lp.slotToItem(slotEnt)

    if itemEnt then
        if slotEnt.canRemoveItemFromSlot and (not slotEnt:canRemoveItemFromSlot(itemEnt)) then
            return false
        end
        return umg.ask("lootplot:canRemoveItemFromSlot", slotEnt, itemEnt)
    end

    return true
end

---@param ppos lootplot.PPos
---@param itemEnt lootplot.ItemEntity
function lp.couldContainItem(ppos, itemEnt)
    local slotEnt = lp.posToSlot(ppos)
    if (not slotEnt) then
        return lp.canItemFloat(itemEnt)
    end

    return lp.couldSlotHoldItem(slotEnt, itemEnt)
end

---Availability: Client and Server
---@param slotEnt lootplot.SlotEntity
---@param itemEnt lootplot.ItemEntity?
---@return boolean
function lp.couldSlotHoldItem(slotEnt, itemEnt)
    --[[
        checks whether or not a slot COULD hold the item,

        We need this check for swapping items.
        (If we use `canAddItem` when swapping items, then we will always
            get false, because theres another item in the slot.)
    ]]
    if umg.exists(itemEnt) then
        if slotEnt.canAddItemToSlot and (not slotEnt:canAddItemToSlot(itemEnt)) then
            return false
        end
        return umg.ask("lootplot:canAddItemToSlot", slotEnt, itemEnt)
    end
    return true
end


---Returns whether an item can float (exist without a slot) or not.
---
---Availability: Client and Server
---@param itemEnt lootplot.ItemEntity
---@return boolean
function lp.canItemFloat(itemEnt)
    return itemEnt.canItemFloat or umg.ask("lootplot:canItemFloat", itemEnt)
end


---@param srcPPos lootplot.PPos
---@param targetPPos lootplot.PPos
local function canMoveFromTo(srcPPos, targetPPos)
    local item = lp.posToItem(srcPPos)
    if not item then
        return true -- its always OK to move nothing.
    end

    return lp.couldContainItem(targetPPos, item) and canRemoveItemOrNoItem(lp.posToSlot(srcPPos))
end

---Availability: Client and Server
---@param ppos1 lootplot.PPos
---@param ppos2 lootplot.PPos
---@return boolean
function lp.canSwapItems(ppos1, ppos2)
    return canMoveFromTo(ppos1, ppos2) and canMoveFromTo(ppos2, ppos1)
end



---@param combinerItem lootplot.ItemEntity
---@param targetItem lootplot.ItemEntity
---@return boolean
function lp.canCombineItems(combinerItem, targetItem)
    if combinerItem.canCombine and combinerItem:canCombine(targetItem) then
        return true
    end
    return umg.ask("lootplot:canCombineItems", combinerItem, targetItem)
end

---@param combinerItem Entity
---@param targetItem Entity
---@return boolean
function lp.tryCombineItems(combinerItem, targetItem)
    assertServer()
    if lp.canCombineItems(combinerItem, targetItem) then
        if combinerItem.onCombine then
            combinerItem:onCombine(targetItem)
        end
        if combinerItem.lives then
            -- lives dont work for combining. 
            -- THAT would be OP.
            combinerItem.lives = 0
        end
        umg.call("lootplot:itemsCombined", combinerItem, targetItem)
        lp.destroy(combinerItem)
        return true
    end
    return false
end



---Availability: Client and Server
---@param ent Entity
---@return boolean
function lp.canActivateEntity(ent)
    if ent.canActivate then
        if not ent:canActivate() then
            return false
        end
    end
    return umg.ask("lootplot:canActivateEntity", ent)
end

---Availability: **Server**
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

---Availability: **Server**
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

---Availability: **Server**
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

---Resets an entity (ie. resets activationCount)
---
---Availability: **Server**
---@param ent Entity
function lp.reset(ent)
    ent.activationCount = 0
    lp.tryTriggerEntity("RESET", ent)
    umg.call("lootplot:entityReset", ent)
    if ent.onReset then
        ent:onReset()
    end
end

---Availability: **Server**
---@param ent lootplot.LayerEntity
function lp.destroy(ent)
    entityTc(ent)
    assertServer()
    if umg.exists(ent) then
        lp.tryTriggerEntity("DESTROY", ent)
        umg.call("lootplot:entityDestroyed", ent)
        if ent.onDestroy then
            ent:onDestroy()
        end
        local ppos = lp.getPos(ent)
        if ppos then
            ppos:clear(ent.layer)
        end
        ptrack.clear(ent)
        ent:delete()
    end
end

---TODO: Implement this on top of our sell system.
---
---Availability: **Server**
---@param ppos lootplot.ItemEntity
function lp.sellItem(ppos)
    -- sells the item at `ppos`
    umg.melt("nyi")
end

-- ---@param ent lootplot.LayerEntity
-- ---@param angle number
-- function lp.rotate(ent, angle)
--     -- TODO.
--     -- rotates `ent` by an angle.
--     --  ent can be a slot OR an item
-- end

---Availability: Client and Server
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
    if not ent:isRegularComponent("buffedProperties") then
        ent.buffedProperties = {
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

---Availability: **Server**
---@param ent Entity
---@param property string
---@param amount number
---@param srcEnt_or_nil Entity? entity that invoked the buff (maybe nil)
function lp.modifierBuff(ent, property, amount, srcEnt_or_nil)
    -- Permanently buffs an entity by adding a flat modifier
    ensureDynamicProperties(ent)
    append(ent.buffedProperties.modifiers, property, amount, reducers.ADD)
    umg.call("lootplot:entityBuffed", property, srcEnt_or_nil)
end

---Availability: **Server**
---@param ent Entity
---@param property string
---@param amount number
---@param srcEnt_or_nil Entity? entity that invoked the buff (maybe nil)
function lp.multiplierBuff(ent, property, amount, srcEnt_or_nil)
    -- Permanently buffs an entity with a multiplier
    ensureDynamicProperties(ent)
    append(ent.buffedProperties.multipliers, property, amount, reducers.MULTIPLY)
    umg.call("lootplot:entityBuffed", property, srcEnt_or_nil)
end



local posEntTc = typecheck.assert("ppos", "entity")

---Availability: **Server**
--- NOTE: This operation will fail if the slot cannot hold the entity!
--- However, if the operation succeeds, the existing item will be deleted.
---@param ppos lootplot.PPos
---@param itemEnt lootplot.ItemEntity
---@nodiscard
---@return boolean
function lp.forceSetItem(ppos, itemEnt)
    posEntTc(ppos, itemEnt)
    assert(itemEnt.item, "Must be a item entity")
    local ok = lp.couldContainItem(ppos, itemEnt)

    if ok then
        local oldItem = lp.posToItem(ppos)
        if oldItem then
            oldItem:delete()
        end
        ppos:set(itemEnt)
        return true
    end
    return false
end



---Availability: **Server**
---@param ppos lootplot.PPos
---@param itemEnt lootplot.ItemEntity
---@nodiscard
---@return boolean
function lp.trySetItem(ppos, itemEnt)
    posEntTc(ppos, itemEnt)
    assert(itemEnt.item, "Must be a item entity")
    if lp.posToItem(ppos) then
        return false
    end
    return lp.forceSetItem(ppos, itemEnt)
end


local spawnTc = typecheck.assert("ppos", "any", "string")

---Availability: **Server**
---@param ppos lootplot.PPos
---@param itemEType EntityType
---@param team string
---@return lootplot.ItemEntity?
function lp.trySpawnItem(ppos, itemEType, team)
    spawnTc(ppos, itemEType, team)
    local preItem = lp.posToItem(ppos)
    if (not preItem) then
        return lp.forceSpawnItem(ppos, itemEType, team)
    end
    return nil
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param itemEType EntityType
---@param team string
---@return lootplot.ItemEntity?
function lp.forceSpawnItem(ppos, itemEType, team)
    spawnTc(ppos, itemEType, team)
    local itemEnt = itemEType()
    assert(itemEnt.item, "forceSpawnItem MUST spawn an item entity!")
    itemEnt.lootplotTeam = team or "?"
    local prevItem = lp.posToItem(ppos)
    if prevItem then
        prevItem:delete()
    end

    if lp.forceSetItem(ppos, itemEnt) then
        umg.call("lootplot:entitySpawned", itemEnt)
        return itemEnt
    else
        -- delete the item: it doesnt fit in slot.
        -- (The reason we needed to create item is because 
        --   we needed to do `lp.couldHoldItem` check)
        itemEnt:delete()
    end
    return nil
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param slotEType EntityType
---@param team string
---@return lootplot.SlotEntity?
function lp.trySpawnSlot(ppos, slotEType, team)
    local preSlotEnt = lp.posToSlot(ppos)
    if not preSlotEnt then
        -- if theres no slot already, spawn:
        return lp.forceSpawnSlot(ppos, slotEType, team)
    end
    return nil
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param slotEType EntityType
---@param team string
---@return lootplot.SlotEntity
function lp.forceSpawnSlot(ppos, slotEType, team)
    local preSlotEnt = lp.posToSlot(ppos)
    if preSlotEnt then
        lp.destroy(preSlotEnt)
    end
    local slotEnt = slotEType()
    slotEnt.lootplotTeam = team or "?"
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





--[[
Q: whats the difference between these two?

A: 
getConstantSpawnWeight is called ONCE, at load-time.
EntityTypes cannot change their weights after they are called.

getDynamicSpawnChance is called multiple times at runtime, within
the generation queries.
(It is a lot less efficient, but provides for greater flexibility)
]]
local function getEntityTypeSpawnWeight(entityType)
    return umg.ask("lootplot:getConstantSpawnWeightMultiplier", entityType) or 1
end

---Availability: **Server**
---@param etypeName string
---@param generationEnt Entity
---@return integer
function lp.getDynamicSpawnChance(etypeName, generationEnt)
    local etype = server.entities[etypeName]

    local value = 1
    if etype.getDynamicSpawnChance then
        value = etype:getDynamicSpawnChance(generationEnt)
    end

    local qbusValue = umg.ask("lootplot:getDynamicSpawnChance", etype, generationEnt) or 1
    return value * qbusValue
end

lp.DEFAULT_ITEM_SPAWN = 1

local LootplotSeed = require("shared.LootplotSeed")
--[[
TODO: allow for custom seeds here.
pass thru launch-options...?
]]
---Availability: Client and Server
lp.SEED = LootplotSeed()

local ITEM_GENERATOR = generation.Generator(lp.SEED.rerollRNG)
local SLOT_GENERATOR = generation.Generator(lp.SEED.rerollRNG)

---Availability: Client and Server
---@param args generation.CloneOptions
---@return generation.Generator
function lp.newItemGenerator(args)
    return ITEM_GENERATOR:cloneWith(lp.SEED.rerollRNG, args)
end

---Availability: Client and Server
---@param args generation.CloneOptions
---@return generation.Generator
function lp.newSlotGenerator(args)
    return SLOT_GENERATOR:cloneWith(lp.SEED.rerollRNG, args)
end

-- If there is an error getting an entity, invalid data is deserialized,
-- Or a generation query fails, 
-- then we SHOULD fall back to these entity-types instead:
---Availability: Client and Server
lp.FALLBACK_NULL_ITEM = false
---Availability: Client and Server
lp.FALLBACK_NULL_SLOT = false
-- Think of these as like "error types".
-- NOTE:: THESE SHOULD BE OVERRIDDEN!



---@class lootplot.LayerEntityClass: EntityClass
---@field public layer string
---@alias lootplot.LayerEntity lootplot.LayerEntityClass|Entity

local strTabTc = typecheck.assert("string", "table")

---@class lootplot.ItemEntityClass: EntityClass
---@field public item true
---@field public layer "item"
---@field public triggers lootplot.Trigger[]
---@field public basePrice number
---@field public pointsGenerated number
---@field public moneyGenerated number
---@field public canItemMove boolean
---@field public canBeDestroyed boolean
---@field public canActivate boolean
---@alias lootplot.ItemEntity lootplot.ItemEntityClass|lootplot.LayerEntity|Entity

---Availability: Client and Server
---@param name string
---@param itemType table<string, any>
function lp.defineItem(name, itemType)
    strTabTc(name, itemType)
    itemType.item = true
    itemType.layer = "item"
    itemType.basePrice = itemType.basePrice or 5
    itemType.triggers = itemType.triggers or {"PULSE"}
    itemType.hitboxDistance = itemType.hitboxDistance or 8
    itemType.hoverable = true
    giveCommonComponents(itemType)

    umg.defineEntityType(name, itemType)
    bufferedEntityTypes:add({
        entityType = itemType,
        name = name,
        generator = ITEM_GENERATOR
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
---@field public itemSpawner? fun(ent:lootplot.SlotEntity): string
---@field public itemReroller? fun(ent:lootplot.SlotEntity): string
---@alias lootplot.SlotEntity lootplot.SlotEntityClass|lootplot.LayerEntity|Entity

local DEFAULT_SLOT_HITBOX_AREA = {width = 22, height = 22, ox = 0, oy = 0}

---Availability: Client and Server
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

    local etype = umg.defineEntityType(name, slotType)
    bufferedEntityTypes:add({
        name = name,
        generator = SLOT_GENERATOR,
        entityType = slotType
    })
    return etype
end


lp.defineTrigger = trigger.defineTrigger
lp.getTriggerDisplayName = trigger.getTriggerDisplayName
lp.isValidTrigger = trigger.isValidTrigger


---Availability: **Server**
---@param name string
---@param ent Entity
function lp.tryTriggerEntity(name, ent)
    return trigger.tryTriggerEntity(name, ent)
end

local EMPTY_TRIGGERS = {}
---@param ent Entity
---@param name string
---@return boolean
function lp.hasTrigger(ent, name)
    for _,t in ipairs(ent.triggers or EMPTY_TRIGGERS) do
        if t == name then
            return true
        end
    end
    return false
end


---Availability: Client and Server
---@param name string
---@param ent Entity
---@return boolean
function lp.canTrigger(name, ent)
    return trigger.canTrigger(name, ent)
end

---Availability: Client and Server
---@param ent lootplot.ItemEntity|lootplot.SlotEntity
---@param clientId string
---@return boolean
function lp.canPlayerAccess(ent, clientId)
    if lp.isItemEntity(ent) then
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and slotEnt.canPlayerAccessItemInSlot then
            if not slotEnt:canPlayerAccessItemInSlot(ent) then
                return false
            end
        end
    end
    return umg.ask("lootplot:hasPlayerAccess", ent, clientId)
end

if client then

---Availability: **Client**
---@return lootplot.Selected?
function lp.getCurrentSelection()
    return selection.getCurrentSelection()
end

---Availability: **Client**
---@return lootplot.EntityHover?
function lp.getHoveredSlot()
    return selection.getHoveredSlot()
end

---Availability: **Client**
---@return lootplot.EntityHover?
function lp.getHoveredItem()
    return selection.getHoveredItem()
end

---Availability: **Client**
---@param item lootplot.ItemEntity
---@param noButtons? boolean Should we not open buttons?
function lp.selectItem(item, noButtons)
    local ppos = lp.getPos(item)
    if ppos then
        if noButtons then
            selection.selectNoButtons(ppos)
        else
            selection.select(ppos)
        end
    end
end

function lp.deselectItem()
    return selection.reset()
end

function lp.getSelectionListener()
    return selection.getListener()
end


end


lp.COLORS = {
    -- BASICS:
    MONEY_COLOR = {1, 0.843, 0.1},
    POINTS_COLOR = {0.3, 1, 0.3},
    POINTS_MULT_COLOR = {0.6, 1, 0.1},
    POINTS_MOD_COLOR = {0.1, 0.9, 0.5},

    -- COMPONENTS:
    LIFE_COLOR = {1, 0.51, 0.75},
    DOOMED_COLOR = {0.7, 0.3, 1},
    DOOMED_LIGHT_COLOR = {0.8, 0.6, 1},

    -- MISC:
    BAD_COLOR = {1, 0.15, 0.2}, -- used for bad stuff
    TRIGGER_COLOR = {0.2, 0.8, 0.9}, -- used for bonuses/good thing
    INFO_COLOR = {1, 1, 0.4},
    COMBINE_COLOR = {0.81, 0.14, 1},
}
if client then
    for id,color in pairs(lp.COLORS) do
        text.defineEffect("lootplot:" .. id, function(_context, char)
            char:setColor(color)
        end)
    end
end


---Availability: Client and Server
lp.constants = {
    WORLD_SLOT_DISTANCE = 26, -- distance slots are apart in the world.
    PIPELINE_DELAY = 0.2
}

umg.on("@load", function(...)
    for _, e in ipairs(bufferedEntityTypes) do
        ---@cast e lootplot._BufferedEtype
        local gen = e.generator
        gen:add(e.name, getEntityTypeSpawnWeight(e.entityType))
    end
end)

if false then
    ---Core Lootplot game API.
    ---
    ---Availability: Client and Server
    _G.lp = lp
end
umg.expose("lp", lp)
return lp
