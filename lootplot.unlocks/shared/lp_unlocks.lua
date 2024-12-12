

assert(not lp.unlocks, "BAH!!!????")
lp.unlocks = {}



lp.defineTrigger("UNLOCK", "Unlock")
--[[
Used when something is "unlocked".

Used for locked-slots,
but also used for chests, and other special items that need unlocking.
]]




if server then

local spawnLockedSlotTc = typecheck.assert("ppos", "entity?", "entity?")


local function forceSpawn(slotType, team, ppos, transformSlotEnt, lockedItemEnt)
    local etype = assert(server.entities[slotType])
    local ent = lp.forceSpawnSlot(ppos, etype, team)

    ent.targetSlot = transformSlotEnt
    ent.targetItem = lockedItemEnt
    return ent
end


local function trySpawn(slotType, team, ppos, transformSlotEnt, lockedItemEnt)
    local etype = assert(server.entities[slotType])
    local ent = lp.trySpawnSlot(ppos, etype, team)
    if ent then
        ent.targetSlot = transformSlotEnt
        ent.targetItem = lockedItemEnt
    end
    return ent
end


local LOCKED_SLOT = "lootplot.unlocks:locked_slot"

---Availability: **Server**
---@param ppos lootplot.PPos
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
function lp.unlocks.forceSpawnLockedSlot(ppos, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local team = "" -- no team
    return forceSpawn(LOCKED_SLOT, ppos, team, transformSlotEnt, lockedItemEnt)
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
---@return lootplot.SlotEntity?
function lp.unlocks.trySpawnLockedSlot(ppos, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local team = "" -- no team
    return trySpawn(LOCKED_SLOT, ppos, team, transformSlotEnt, lockedItemEnt)
end



local MYSTERY_SLOT = "lootplot.unlocks:mystery_slot"

---Availability: **Server**
---@param ppos lootplot.PPos
---@param unlockLevel number
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
function lp.unlocks.forceSpawnMysterySlot(ppos, unlockLevel, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local team = (transformSlotEnt or lockedItemEnt).lootplotTeam or ""
    local slot = forceSpawn(MYSTERY_SLOT, team, ppos, transformSlotEnt, lockedItemEnt)
    if slot then
        slot.unlockLevel = unlockLevel
    end
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param unlockLevel number
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
---@return lootplot.SlotEntity?
function lp.unlocks.trySpawnMysterySlot(ppos, unlockLevel, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local team = (transformSlotEnt or lockedItemEnt).lootplotTeam or ""
    local slot = trySpawn(MYSTERY_SLOT, team, ppos, transformSlotEnt, lockedItemEnt)
    if slot then
        slot.unlockLevel = unlockLevel
    end
end

end
