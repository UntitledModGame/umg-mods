

assert(not lp.unlocks, "BAH!!!????")
lp.unlocks = {}



lp.defineTrigger("UNLOCK", "Unlock")
--[[
Used when something is "unlocked".

Used for locked-slots,
but also used for chests, and other special items that need unlocking.
]]




if server then

local spawnLockedSlotTc = typecheck.assert("ppos", "entity", "entity")

---@param ppos lootplot.PPos
---@param transformSlotEnt Entity The slot-entity to be transformed into
---@param lockedItemEnt Entity The item-entity to be transformed into
function lp.unlocks.spawnLockedSlot(ppos, transformSlotEnt, lockedItemEnt)
    spawnLockedSlotTc(ppos, transformSlotEnt, lockedItemEnt)
    --[[
    TODO: implement this.
    ]]
end

end

