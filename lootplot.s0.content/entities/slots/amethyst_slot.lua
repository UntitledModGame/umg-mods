local loc = localization.localize

local DESCRIPTION = localization.newInterpolator("Upgrades items.\nTransform to %{name} once used.")

return lp.defineSlot("lootplot.s0.content:amethyst_slot", {
    image = "amethyst_slot",
    name = loc("Amethyst slot"),
    description = function(self)
        return DESCRIPTION({
            rarity = self.minRarity.displayString,
            name = (server or client).entities[self.transformTo].name
        })
    end,
    baseMaxActivations = 1,
    triggers = {"PULSE"},
    baseCanSlotPropagate = false,

    transformTo = "lootplot.s0.content:slot",
    minRarity = lp.rarities.RARE,

    -- TODO: Use slot listener? Eh this will do for now.
    onActivate = function(self)
        local itemEnt = lp.slotToItem(self)

        if itemEnt and (
            (itemEnt.rarity and lp.rarities.getWeight(itemEnt.rarity) <= lp.rarities.getWeight(self.minRarity)) or
            itemEnt.price >= 20
        )
        then
            local ppos = assert(lp.getPos(self))
            umg.melt("Todo: upgrade item somehow")
            lp.forceSpawnSlot(ppos, server.entities[self.transformTo], self.lootplotTeam)
        end
    end
})
