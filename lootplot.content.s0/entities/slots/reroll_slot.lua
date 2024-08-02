
return lp.defineSlot("lootplot.content.s0:reroll_slot", {
    image = "paper_slot",
    -- TODO: do a better image for this. Maybe a green one?
    name = localization.localize("Reroll slot"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    baseCanSlotPropagate = false,
    onActivate = function(shopEnt)
        shopEnt.shopLock = true
    end
})


