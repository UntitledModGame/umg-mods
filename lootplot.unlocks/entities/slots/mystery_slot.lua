
local loc = localization.localize
local interp = localization.localize


local DESC = interp("Unlocks on level %{levelNumber}.")

lp.defineSlot("lootplot.unlocks:mystery_slot", {
    image = "mystery_slot",
    name = loc("Mystery Slot"),
    description = function(ent)
        return DESC({
            levelNumber = ent.unlockLevel or 1000
        })
    end,

    triggers = {"PULSE"},

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,

    ---@param self lootplot.SlotEntity
    onActivate = function(self)
        if self.levelNumber < lp.getLevel(self) then
            return
        end

        -- else: ITS TIME!!! Begin the unlock process.
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
            tslot:removeComponent("audioVolume")
            lp.setSlot(ppos, tslot)
        end

        if titem then
            if lp.forceSetItem(ppos, titem) then
                titem:removeComponent("audioVolume")
            else
                titem:delete()
            end
        end
    end
})
