lp.defineSlot("lootplot.main:debugslot", {
    triggers = {"PULSE"},
    baseCanSlotPropagate = false,

    onActivate = function(self)
        if not self.target then return end
        lp.forceSpawnItem(assert(lp.getPos(self)), server.entities[self.target], self.lootplotTeam)
    end
})