

return lp.defineSlot("lootplot.content.s0:shop_slot", {
    image = "cloth_slot_2",
    color = {1, 1, 0.6},
    shopLock = true,
    name = localization.localize("Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    itemReroller = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    baseCanSlotPropagate = false,
    onActivate = function(shopEnt)
        shopEnt.shopLock = true
    end
})

