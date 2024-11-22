local loc = localization.localize

lp.defineSlot("lootplot.unlocks:locked_slot", {
    image = "locked_slot",
    name = loc("Locked Slot"),
    description = loc("{i}What does it contain?{/i}"),
    triggers = {"UNLOCK"},
    locked = true,

    ---@param self lootplot.SlotEntity
    onActivate = function(self)
        if self.locked then
            return
        end

        local ppos = assert(lp.getPos(self))
        local tslot = self.targetSlot
        local titem = self.targetItem

        self:removeComponent("targetSlot")
        self:removeComponent("targetItem")
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

        lp.destroy(self)
    end
})
