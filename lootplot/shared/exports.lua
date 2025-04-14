
--[[

Global api helper methods.
slotGrid
]]

local ptrack = require("shared.internal.positionTracking")
local selection = require("shared.selection")


---@alias lootplot._BufferedEtype {name:string, entityType:table, generator:generation.Generator}

-- We need to buffer-define entity-types, 
-- so future mods have opportunities to modify them
local bufferedEntityTypes = objects.Array()

---Availability: Client and Server
---@class lootplot
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


---Availability: **Client**
---@param ent Entity
---@return (string | function)[]
function lp.getDescriptionTags(ent)
    local array = objects.Array()
    --[[
    description-tags are tiny bits of text that are self-explanatory,
    and dont need a proper description.

    EG: Rarity, Price 
    COMMON(I), $5

    ^^^ these dont need an explanation!
    Basically, this system exists so we can condense information a bit,
    and be a bit less overwhelming for the player.
    ]]
    umg.call("lootplot:populateDescriptionTags", ent, array)
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
---@param ent_or_etype Entity|EntityType
---@return boolean
function lp.isSlotEntity(ent_or_etype)
    return not not ent_or_etype.slot
end

---Availability: Client and Server
---@param ent_or_etype Entity|EntityType
---@return boolean
function lp.isItemEntity(ent_or_etype)
    return not not ent_or_etype.item
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
    SLOT_NO_ITEM = "SLOT_NO_ITEM", -- empty slots
    NO_ITEM = "NO_ITEM", -- ppos with no item
    NO_SLOT = "NO_SLOT", -- ppos with no slot
}

---@alias lootplot.CONVERSION_TYPE "ITEM"|"SLOT"|"NO_SLOT"|"NO_ITEM"|"ITEM_OR_SLOT"|"SLOT_OR_ITEM"|"SLOT_NO_ITEM"

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
    elseif conversionType == "SLOT_NO_ITEM" then
        local slot = lp.posToSlot(ppos)
        if slot and not lp.posToItem(ppos) then
            return true, slot
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
lp.rawsetAttribute = attributes.rawsetAttribute
lp.getAllAttributes = attributes.getAllAttributes
lp.modifyAttribute = attributes.modifyAttribute
lp.getAttributeDefault = attributes.getAttributeDefault

lp.defineAttribute = attributes.defineAttribute

lp.defineAttribute("MONEY", 0)
lp.defineAttribute("POINTS", 0)
lp.defineAttribute("POINTS_MULT", 1)
lp.defineAttribute("POINTS_BONUS", 0)

-- COMBO = number of successive activations without interruption.
lp.defineAttribute("COMBO", 0)



----------------------------
-- OPTIONAL ATTRIBUTES:::
----------------------------

-- "LEVEL" is a general difficulty indicator.
-- higher level = higher difficulty.
lp.defineAttribute("LEVEL", 1)

-- ROUND = current round number
lp.defineAttribute("ROUND", 1)
---@param ent Entity
---@return number
function lp.getRound(ent)
    return lp.getAttribute("ROUND", ent)
end
---@param ent Entity
---@param x number
function lp.setRound(ent, x)
    lp.setAttribute("ROUND", ent, x)
end



local ROUNDS_PER_LEVEL = 6
lp.defineAttribute("NUMBER_OF_ROUNDS", ROUNDS_PER_LEVEL)
-- The number of rounds allowed per level
-- (should generally be kept constant.)
-- (Typically, if ROUND > NUMBER_OF_ROUNDS, lose.)
-- However, this attribute can be used however you like.

---Availability: Client and Server
---@param ent Entity
---@return number
function lp.getNumberOfRounds(ent)
    return lp.getAttribute("NUMBER_OF_ROUNDS", ent)
end


lp.defineAttribute("REQUIRED_POINTS", -1)
-- The required-points for some condition.
-- Can be used in any way that is deemed fit

---@param ent Entity
---@return number
function lp.getRequiredPoints(ent)
    return lp.getAttribute("REQUIRED_POINTS", ent)
end


-- IMPORTANT NOTE::::
-- Note that these "optional attributes" don't *need* to be used.
-- It depends on the gamemode.
-- Perhaps some gamemode use all the attributes;
-- Perhaps another gamemode uses only the required ones.
-- Perhaps another gamemode defines it's own custom attributes!
-- It's entirely up to you.




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

--- (Doesn't include multiplier or bonus!!!)
---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.addPointsRaw(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.modifyAttribute("POINTS", fromEnt, x)
end


---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.addPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    local mult = lp.getPointsMult(fromEnt) or 1
    local bonus = (lp.getPointsBonus(fromEnt) or 0)

    local val = x * mult
    local bonusVal = bonus * mult

    -- normal points:
    lp.addPointsRaw(fromEnt, val)
    umg.call("lootplot:pointsChangedViaCall", fromEnt, val)

    -- bonus mechanism:
    local ppos = lp.getPos(fromEnt)
    if ppos and bonusVal ~= 0 then
        lp.wait(ppos, 0.1) -- LIFO
        lp.queueWithEntity(fromEnt, function(ent)
            umg.call("lootplot:pointsChangedViaBonus", fromEnt, bonusVal)
            lp.addPointsRaw(ent, bonusVal)
        end)
        lp.wait(ppos, 0.1) -- LIFO
    end
end


---Availability: Client and Server
---@param ent Entity
---@return number?
function lp.getPoints(ent)
    entityTc(ent)
    return lp.getAttribute("POINTS", ent)
end




---Availability: Client and Server
---@param fromEnt Entity
---@return number?
function lp.getPointsBonus(fromEnt)
    entityTc(fromEnt)
    return lp.getAttribute("POINTS_BONUS", fromEnt)
end

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.addPointsBonus(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.modifyAttribute("POINTS_BONUS", fromEnt, x)
end

---Availability: **Server**
---@param fromEnt Entity
---@param x number
function lp.setPointsBonus(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.setAttribute("POINTS_BONUS", fromEnt, x)
end




---Availability: Client and Server
---@param fromEnt Entity
---@return number?
function lp.getPointsMult(fromEnt)
    entityTc(fromEnt)
    return lp.getAttribute("POINTS_MULT", fromEnt)
end

---Availability: Server
---@param fromEnt Entity
---@return number?
function lp.setPointsMult(fromEnt, x)
    entityTc(fromEnt)
    lp.setAttribute("POINTS_MULT", fromEnt, x)
end

---Availability: Server
---@param fromEnt Entity
function lp.addPointsMult(fromEnt, x)
    entityTc(fromEnt)
    lp.modifyAttribute("POINTS_MULT", fromEnt, x)
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



---@param itemEnt Entity the item
---@return boolean canRemove true if we can remove the item from ppos, false if we cannot.
function lp.canRemoveItem(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    local ppos = lp.getPos(itemEnt)
    if not ppos then
        umg.log.error("Ahem, wot wot????")
        return false -- ?? wot wot??
    end
    if slotEnt and slotEnt.canRemoveItemFromSlot and (not slotEnt:canRemoveItemFromSlot(itemEnt)) then
        return false
    end
    return umg.ask("lootplot:canRemoveItem", itemEnt, ppos)
end



---Availability: Client and Server
---@param slotEnt lootplot.SlotEntity
---@param itemEnt lootplot.ItemEntity?
---@return boolean
local function couldSlotHoldItem(slotEnt, itemEnt)
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
    end
    return true
end



---@param ppos lootplot.PPos
---@param itemEnt lootplot.ItemEntity
---@return boolean
--- True if a ppos could contain an item; false otherwise
function lp.couldContainItem(ppos, itemEnt)
    local slotEnt = lp.posToSlot(ppos)
    local ok
    if (slotEnt) then
        ok = couldSlotHoldItem(slotEnt, itemEnt)
    else
        local plot = ppos:getPlot()
        ok = lp.canItemFloat(itemEnt) and plot:isFogRevealed(ppos, itemEnt.lootplotTeam)
    end

    return ok and umg.ask("lootplot:canAddItem", itemEnt, ppos)
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

    if not lp.couldContainItem(targetPPos, item) then
        return false
    end

    return lp.canRemoveItem(item)
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
    if ent.onPostActivate then
        ent:onPostActivate()
    end
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
function lp.resetEntity(ent)
    ent.activationCount = 0
    lp.tryTriggerEntity("RESET", ent)
    umg.call("lootplot:entityReset", ent)
    if ent.onReset then
        ent:onReset()
    end
end



---@param ent lootplot.LayerEntity
---@param ppos lootplot.PPos?
local function deleteInstantly(ent, ppos)
    ppos = ppos or lp.getPos(ent)
    if ppos then
        ppos:clear(ent.layer)
    end
    ptrack.clear(ent)
    ent:delete()
end

---Availability: **Server**
---@param ent lootplot.LayerEntity
function lp.destroy(ent)
    entityTc(ent)
    assertServer()
    if umg.exists(ent) then
        local canDelete = not lp.isInvincible(ent)
        if ent.lives then
            ent.lives = ent.lives - 1
        end
        lp.tryTriggerEntity("DESTROY", ent)
        umg.call("lootplot:entityDestroyed", ent)
        if ent.onDestroy then
            ent:onDestroy()
        end

        if canDelete then
            deleteInstantly(ent)
        end
    end
end



--- Checks if an entity is invincible.
--- If an entity is invincible, it will remain alive even after lp.destroy has been called.
---@param ent lootplot.LayerEntity
---@return boolean 
function lp.isInvincible(ent)
    if ent.lives and ent.lives > 0 then
        return true
    end
    if type(ent.isInvincible) == "function" and ent:isInvincible() then
        return true
    end
    return umg.ask("lootplot:isInvincible", ent)
end



--- Gets rotation count as an integer.
--- 0 = 0 degrees, 1 = 90 degrees, 2 = 180, etc.
--- Cannot have non-integer rotations.
---@param ent Entity
---@return integer
function lp.getItemRotation(ent)
    return (ent.lootplotRotation or 0) % 4
end


local rotateItemTc = typecheck.assert("entity", "number?")

---@param ent lootplot.ItemEntity
---@param amount number Rotation amount, as an integer. 1 = 90 degrees.
--- rotates `ent` by an amount.
function lp.rotateItem(ent, amount)
    rotateItemTc(ent, amount)
    amount = math.max(0, math.floor((amount or 1) + 0.5)) % 4
    local oldRot = lp.getItemRotation(ent)
    local newRot = (oldRot + amount) % 4
    umg.log.trace("Rotating item: ", ent, amount)
    lp.tryTriggerEntity("ROTATE", ent)
    umg.call("lootplot:itemRotated", ent, amount, oldRot, newRot)
    ent.lootplotRotation = newRot
end



local setItemRotTc = typecheck.assert("entity", "number")

---@param ent lootplot.ItemEntity
---@param rot number Rotation amount, as an integer. 1 = 90 degrees.
--- Sets ent rotation to a specific value.
function lp.setItemRotation(ent, rot)
    setItemRotTc(ent, rot)
    rot = math.max(0, math.floor((rot or 1) + 0.5)) % 4
    local curRot = lp.getItemRotation(ent)
    local deltaRot = rot - curRot
    lp.rotateItem(ent, deltaRot)
end







---Availability: Client and Server
---@generic T: EntityClass
---@param ent T
---@return T
function lp.clone(ent)
    ---@diagnostic disable-next-line: undefined-field
    local cloned = ent:clone()
    --[[
        TODO: emit events here?
    ]]
    return cloned
end


--- Force-clones an item, using `lp.forceSetItem`.
--- If an item already exists, the old item is deleted.
--- This operation can still fail though; 
--- (if the ppos cannot contain the item)
---@param cloneEnt Entity
---@param ppos lootplot.PPos
---@return Entity?
function lp.forceCloneItem(cloneEnt, ppos)
    local ent = lp.clone(cloneEnt)
    local success = lp.forceSetItem(ppos, ent)
    if not success then
        ent:delete()
        return nil
    end
    lp.tryTriggerEntity("SPAWN", ent)
    return ent
end


--- Tries to clone an item, using `lp.trySetItem`.
--- If an item already exists, this operation fails.
---@param cloneEnt Entity
---@param ppos lootplot.PPos
---@return Entity?
function lp.tryCloneItem(cloneEnt, ppos)
    local ent = lp.clone(cloneEnt)
    local success = lp.trySetItem(ppos, ent)
    if not success then
        ent:delete()
        return nil
    end
    lp.tryTriggerEntity("SPAWN", ent)
    return ent
end



--- Tries to clone a slot, using `lp.trySetItem`.
--- If a slot already exists, the old slot is deleted.
---@param cloneEnt Entity
---@param ppos lootplot.PPos
---@return Entity
function lp.forceCloneSlot(cloneEnt, ppos)
    local ent = lp.clone(cloneEnt)
    lp.setSlot(ppos, ent)
    lp.tryTriggerEntity("SPAWN", ent)
    return ent
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


local buffTc = typecheck.assert("entity", "string", "number", "entity?")
---Availability: **Server**
---@param ent Entity
---@param property string
---@param amount number
---@param srcEnt_or_nil Entity? entity that invoked the buff (maybe nil)
function lp.modifierBuff(ent, property, amount, srcEnt_or_nil)
    buffTc(ent, property, amount, srcEnt_or_nil)
    assert(properties.getPropertyType(property), "Invalid property: " .. property)
    -- Permanently buffs an entity by adding a flat modifier
    ensureDynamicProperties(ent)
    append(ent.buffedProperties.modifiers, property, amount, reducers.ADD)
    umg.call("lootplot:entityBuffed", ent, property, amount, srcEnt_or_nil)
    sync.syncComponent(ent, "buffedProperties")
end



local posEntTc = typecheck.assert("ppos", "entity")

---NOTE: This operation will fail if the slot cannot hold the entity!
---However, if the operation succeeds, the existing item will be deleted.
---
---Availability: **Server**
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
            deleteInstantly(oldItem, ppos)
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
        lp.tryTriggerEntity("SPAWN", itemEnt)
        return itemEnt
    else
        -- delete the item: it doesnt fit in slot.
        -- (The reason we needed to create item is because 
        --   we needed to do `lp.couldHoldItem` check)
        deleteInstantly(itemEnt, ppos)
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
    lp.tryTriggerEntity("SPAWN", slotEnt)
    return slotEnt
end




local validTags = {}

typecheck.addType("lootplot:tag", function (x)
    return validTags[x], "Expected lootplot tag"
end)

---Availability: Client and Server
---@param ent_or_etype table
---@return table
function lp.getTags(ent_or_etype)
    return ent_or_etype.lootplotTags or {}
end

local ttc = typecheck.assert("table", "lootplot:tag")
---Availability: Client and Server
---@param ent_or_etype table
---@param tag string
---@return boolean
function lp.hasTag(ent_or_etype, tag)
    ttc(ent_or_etype, tag)
    local tags = lp.getTags(ent_or_etype)
    if not tags then return false end
    -- linear search is fine; we dont expect too many tags per etype.
    for _, t in ipairs(tags) do
        if t == tag then
            return true
        end
    end
    return false
end

---Availability: Client and Server
---@param tagName string
function lp.defineTag(tagName)
    validTags[tagName] = true
end

---Availability: Client and Server
---@param tagName string
function lp.isValidTag(tagName)
    return validTags[tagName]
end



local DEFAULT_PROPS = {
    "pointsGenerated",
    "moneyGenerated",
    "multGenerated",
    "bonusGenerated",
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



local function assertTriggersValid(name, triggers)
    for _, t in ipairs(triggers) do
        if not lp.isValidTrigger(t) then
            umg.melt("invalid trigger: '"..t.."'" .. " for " .. tostring(name))
        end
    end
end

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
---@field public canActivate boolean
---@alias lootplot.ItemEntity lootplot.ItemEntityClass|lootplot.LayerEntity|Entity

---Availability: Client and Server
---@param name string
---@param itemType table<string, any>
function lp.defineItem(name, itemType)
    strTabTc(name, itemType)

    if not itemType.basePrice then
        umg.log.warn("item not given base-price: ", name)
    end
    if not itemType.baseMaxActivations then
        umg.log.warn("item not given baseMaxActivations", name)
    end

    itemType.item = true
    itemType.layer = "item"
    itemType.basePrice = itemType.basePrice or 5
    itemType.triggers = itemType.triggers or {}
    itemType.hitboxDistance = itemType.hitboxDistance or 8
    itemType.hoverable = true
    giveCommonComponents(itemType)
    assertTriggersValid(name, itemType.triggers)

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
---@field public canActivate boolean
---@field public dontPropagateTriggerToItem boolean
---@field public buttonSlot boolean
---@field public onActivate? fun(ent:lootplot.SlotEntity)
---@alias lootplot.SlotEntity lootplot.SlotEntityClass|lootplot.LayerEntity|Entity

local DEFAULT_SLOT_HITBOX_AREA = {width = 22, height = 22, ox = 0, oy = 0}

---Availability: Client and Server
---@param name string
---@param slotType table<string, any>
function lp.defineSlot(name, slotType)
    strTabTc(name, slotType)
    if not slotType.rarity then
        umg.log.warn("!!! SLOT NOT GIVEN RARITY:", name)
    end

    slotType.slot = true
    slotType.layer = "slot"
    slotType.drawDepth = -200
    slotType.triggers = slotType.triggers or {}
    slotType.hitboxArea = slotType.hitboxArea or DEFAULT_SLOT_HITBOX_AREA
    slotType.hoverable = true
    giveCommonComponents(slotType)
    assertTriggersValid(name, slotType.triggers)

    umg.defineEntityType(name, slotType)
    bufferedEntityTypes:add({
        name = name,
        generator = SLOT_GENERATOR,
        entityType = slotType
    })
end











do--TRIGGERS

local triggerInfo = {}


typecheck.addType("lootplot:trigger", function(x)
    return type(x) == "string" and triggerInfo[x], "expected trigger"
end)

local defineTriggerTc = typecheck.assert("string", "string")

---Availability: Client and Server
---@param id string
---@param displayName string
function lp.defineTrigger(id, displayName)
    defineTriggerTc(id, displayName)
    assert(not triggerInfo[id], "trigger name already defined")
    triggerInfo[id] = {
        displayName = localization.localize(displayName)
    }
end

local strTc = typecheck.assert("string")

---Availability: Client and Server
---@param id string
---@return string
function lp.getTriggerDisplayName(id)
    strTc(id)
    assert(lp.isValidTrigger(id), "Invalid trigger")
    return assert(triggerInfo[id].displayName)
end

---Availability: Client and Server
---@param id string
---@return boolean
function lp.isValidTrigger(id)
    strTc(id)
    return triggerInfo[id]
end


local triggerTc = typecheck.assert("lootplot:trigger", "entity")
local EMPTY = {}

---Availability: **Server**
---@param name string
---@param ent Entity
---@return boolean succeeded whether the entity was triggered successfully
function lp.tryTriggerEntity(name, ent)
    assert(server, "server-side function only")
    triggerTc(name, ent)

    local canTrigger = lp.canTrigger(name, ent)
    umg.call("lootplot:entityTriggered", name, ent)
    if canTrigger then
        lp.tryActivateEntity(ent)
    else
        umg.call("lootplot:entityTriggerFailed", name, ent)
    end
    if ent.onTriggered then
        ent:onTriggered(name, canTrigger)
    end

    return canTrigger
end


--- Tries to trigger a slot, THEN triggers the item afterwards.
--- If the slot doesn't propagate triggers (eg shop-slot, null-slot,)
--- Then the item isn't triggered.
---@param name lootplot.Trigger
---@param ppos lootplot.PPos
function lp.tryTriggerSlotThenItem(name, ppos)
    --[[
    triggers slot, then triggers item.
    (Useful for Pulse-button-slot, or Reroll-button-slot)
    ]]
    local slotEnt = lp.posToSlot(ppos)
    local itemEnt = lp.posToItem(ppos)
    if slotEnt then
        lp.tryTriggerEntity(name, slotEnt)

        local canPropagate = lp.canSlotPropagateTriggerToItem(slotEnt)
        if itemEnt and canPropagate then
            -- TODO: We should probably standardize this delay somehow???
            lp.wait(ppos, 0.2)
            lp.queueWithEntity(itemEnt, function(itemEntt)
                lp.tryTriggerEntity(name, itemEntt)
            end)
        end
    else
        if itemEnt then
            lp.tryTriggerEntity(name, itemEnt)
        end
    end
end



---@param ent_or_etype Entity
---@return boolean canPropagate If the slot can propagate trigger to item
function lp.canSlotPropagateTriggerToItem(ent_or_etype)
    assert(lp.isSlotEntity(ent_or_etype))
    return not ent_or_etype.dontPropagateTriggerToItem
end




local EMPTY_TRIGGERS = {}
---@param ent_or_etype Entity|EntityType
---@param name string
---@return boolean
function lp.hasTrigger(ent_or_etype, name)
    for _,t in ipairs(ent_or_etype.triggers or EMPTY_TRIGGERS) do
        if t == name then
            return true
        end
    end
    return false
end

---@param ent Entity
---@param triggerName string
function lp.addTrigger(ent, triggerName)
    assert(lp.isValidTrigger(triggerName))
    if not lp.hasTrigger(ent, triggerName) then
        local triggers = objects.Array(ent.triggers or {})
        triggers:add(triggerName)
        ent.triggers = triggers
        sync.syncComponent(ent, "triggers")
    end
end

---@param ent Entity
---@param triggers table
function lp.setTriggers(ent, triggers)
    for _,v in ipairs(triggers) do
        assert(lp.isValidTrigger(v))
    end

    -- defensive copy to be safe
    ent.triggers = objects.Array(triggers)
    sync.syncComponent(ent, "triggers")
end


-- HMM:
-- Should we add `lp.removeTrigger` here in the future...?


---Availability: Client and Server
---@param name string
---@param ent Entity
---@return boolean
function lp.canTrigger(name, ent)
    local ok = umg.ask("lootplot:canTrigger", name, ent)
    if not ok then
        return false
    end
    local triggers = ent.triggers or EMPTY
    for _, t in ipairs(triggers) do
        if t == name then
            return true
        end
    end
    return false
end

sync.proxyEventToClient("lootplot:entityTriggered")

lp.defineTrigger("REROLL", "Reroll")
lp.defineTrigger("PULSE", "Pulse")
lp.defineTrigger("RESET", "Reset")
lp.defineTrigger("DESTROY", "Destroyed")
lp.defineTrigger("BUY", "Buy")
lp.defineTrigger("ROTATE", "Rotate")
lp.defineTrigger("SPAWN", "Spawn")
lp.defineTrigger("LEVEL_UP", "Level-Up")

---@alias lootplot.Trigger "REROLL"|"PULSE"|"RESET"|"DESTROY"|"BUY"|"ROTATE"|"SPAWN"|"LEVEL_UP"

end--TRIGGERS












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


---@type table<string, string?>
local playerTeams = {}

umg.definePacket("lootplot:setPlayerTeam", {typelist = {"string", "string"}})

---Availability: Client and Server
---@param clientId string
---@return string?
function lp.getPlayerTeam(clientId)
    return playerTeams[clientId]
end




local metaprogression = require("shared.metaprogression")

lp.metaprogression = {}

lp.metaprogression.defineFlag = metaprogression.defineFlag
lp.metaprogression.isValidFlag = metaprogression.isValidFlag
lp.metaprogression.getFlag = metaprogression.getFlag
lp.metaprogression.setFlag = metaprogression.setFlag

lp.metaprogression.defineStat = metaprogression.defineStat
lp.metaprogression.isValidStat = metaprogression.isValidStat
lp.metaprogression.setStat = metaprogression.setStat
lp.metaprogression.getStat = metaprogression.getStat


---@param etype table
---@return boolean isUnlocked whether the etype is unlocked or not
function lp.metaprogression.isEntityTypeUnlocked(etype)
    if etype.isEntityTypeUnlocked then
        return etype:isEntityTypeUnlocked()
    end
    return true
end


lp.metaprogression.defineStat("lootplot:WIN_COUNT", 0)


---Gets the win count.
---@return number
function lp.getWinCount()
    -- gets the win count stored on this machines.
    -- NOTE: If you are playing multiplayer, this will return the win count
    -- of the HOST. Not any other player!!!

    -- (ultimately, stats are only really meaningful in singleplayer modes)
    return lp.metaprogression.getStat("lootplot:WIN_COUNT") or 0
end



local winGroup = umg.group("onWinGame")

--- Signals the winning of the game for a player
---@param clientId string
function lp.winGame(clientId)
    lp.metaprogression.setStat("lootplot:WIN_COUNT", lp.getWinCount() + 1)
    umg.call("lootplot:winGame", clientId)
    for _, ent in ipairs(winGroup) do
        ent:onWinGame()
    end
end

--- Signals the losing of the game for a player
---@param clientId string
function lp.loseGame(clientId)
    umg.call("lootplot:loseGame", clientId)
end



if server then

local setPlayerTeamTc = typecheck.assert("string", "string?")

---Availability: **Server**
---@param clientId string
---@param team string?
function lp.setPlayerTeam(clientId, team)
    setPlayerTeamTc(clientId, team)
    playerTeams[clientId] = team
    server.broadcast("lootplot:setPlayerTeam", clientId, json.encode(team))
end

-- TODO: Hook into @playerLeave to unset the team mapping.

else

client.on("lootplot:setPlayerTeam", function(clientId, teamEncoded)
    playerTeams[clientId] = json.decode(teamEncoded)
end)

end -- if server



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


end -- if client




-- items cannot get more than this number of maxActivations
-- (this is done to ensure that games dont go on FOREVER)
lp.MAX_ACTIVATIONS_LIMIT = 40
-- ^^^ feel free to monkeypatch this value btw.
-- Qbuses are fully stateless, so you can change it whenever, to whatever value you want.




lp.COLORS = {
    -- BASICS:
    MONEY_COLOR = {1, 0.843, 0.1},
    POINTS_COLOR = {0.3, 1, 0.3},
    POINTS_MULT_COLOR = {0.92, 0.32, 0.46}, -- eb5276
    POINTS_MOD_COLOR = {0.1, 0.9, 0.5},
    BONUS_COLOR = {173/255, 255/255, 250/255},

    -- COMPONENTS:
    LIFE_COLOR = {1, 0.51, 0.75},
    DOOMED_COLOR = {0.7, 0.3, 1},
    DOOMED_LIGHT_COLOR = {0.8, 0.6, 1},

    STUCK_COLOR = {210/255, 210/255, 70/255},

    GRUB_COLOR = {0.78, 0.65, 0.13},
    GRUB_COLOR_LIGHT = {1,0.85,0.43},

    REPEATER_COLOR = {0.84, 0.24, 0.13},
    REPEATER_COLOR_LIGHT = {0.96, 0.63, 0.37},

    -- MISC:
    BAD_COLOR = {1, 0.15, 0.2}, -- used for bad stuff
    TRIGGER_COLOR = {0.2, 0.8, 0.9}, -- used for bonuses/good thing
    INFO_COLOR = {1, 1, 0.4},
    COMBINE_COLOR = {0.81, 0.14, 1},
    LISTEN_COLOR = {0.35, 0.65, 1},
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
        gen:add(e.name, 1)
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
