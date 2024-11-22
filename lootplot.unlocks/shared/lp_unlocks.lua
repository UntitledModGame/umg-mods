

assert(not lp.unlocks, "BAH!!!????")
lp.unlocks = {}



lp.defineTrigger("UNLOCK", "Unlock")
--[[
Used when something is "unlocked".

Used for locked-slots,
but also used for chests, and other special items that need unlocking.
]]




if server then

local lockedslotEType = require("entities.slots.locked_slot")

local spawnLockedSlotTc = typecheck.assert("ppos", "string", "entity?", "entity?")

---Availability: **Server**
---@param ppos lootplot.PPos
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
function lp.unlocks.forceSpawnLockedSlot(ppos, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local ent = lp.forceSpawnSlot(ppos, lockedslotEType, "") -- no team

    ent.targetSlot = transformSlotEnt
    ent.targetItem = lockedItemEnt
    return ent
end

---Availability: **Server**
---@param ppos lootplot.PPos
---@param transformSlotEnt lootplot.SlotEntity? The slot-entity to be transformed into
---@param lockedItemEnt lootplot.ItemEntity? The item-entity to be transformed into
---@return lootplot.SlotEntity?
function lp.unlocks.trySpawnLockedSlot(ppos, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    local ent = lp.trySpawnSlot(ppos, lockedslotEType, "") -- no team

    if ent then
        ent.targetSlot = transformSlotEnt
        ent.targetItem = lockedItemEnt
    end

    return ent
end

end
