

return lp.defineSlot("lootplot.content.s0:shop_slot", {
    image = "shop_slot",
    color = {1, 1, 0.6},
    baseMaxActivations = 100,
    shopLock = true,
    name = localization.localize("Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = {},
    itemReroller = {},
    baseCanSlotPropagate = false,
    onActivate = function(shopEnt)
        shopEnt.shopLock = true
    end
})

