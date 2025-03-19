lp.defineSlot("lootplot.singleplayer:debugslot", {
    triggers = {"PULSE"},

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,
    audioVolume = 0,

    onActivate = function(self)
        if not self.target then return end
        lp.forceSpawnItem(assert(lp.getPos(self)), server.entities[self.target], self.lootplotTeam)
    end
})
