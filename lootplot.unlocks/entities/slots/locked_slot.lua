local loc = localization.localize

local function triggerUnlock(ent)
    return lp.tryTriggerEntity("UNLOCK", ent)
end

---@param ppos lootplot.PPos
---@param x integer
---@param y integer
local function consider(ppos, x, y)
    local targPPos = ppos:move(x, y)
    if targPPos then
        local slotEnt = lp.posToSlot(targPPos)
        if slotEnt and lp.hasTrigger(slotEnt, "UNLOCK") then
            lp.queueWithEntity(slotEnt, triggerUnlock)
            lp.wait(ppos, 0.2)
        end
    end
end

lp.defineSlot("lootplot.unlocks:locked_slot", {
    image = "locked_slot",
    name = loc("Locked Slot"),
    description = loc("{i}What does it contain?{/i}"),
    triggers = {"UNLOCK"},
    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,

    ---@param self lootplot.SlotEntity
    onActivate = function(self)
        local ppos = assert(lp.getPos(self))
        local tslot = self.targetSlot
        local titem = self.targetItem

        self:removeComponent("targetSlot")
        self:removeComponent("targetItem")
        self.targetSlot = nil
        self.targetItem = nil
        lp.destroy(self)

        -- sync.syncComponent(self, "targetSlot")
        -- sync.syncComponent(self, "targetItem")

        if tslot then
            lp.setSlot(ppos, tslot)
        end

        if titem then
            if not lp.forceSetItem(ppos, titem) then
                titem:delete()
            end
        end

        consider(ppos, -1, 0)
        consider(ppos, 0, -1)
        consider(ppos, 1, 0)
        consider(ppos, 0, 1)
    end
})
