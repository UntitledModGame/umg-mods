

return lp.defineSlot("lootplot:shopSlot", {
    image = "slot",
    color = {1, 1, 0.6},
    shopLock = true,
    triggers = {"REROLL", "PULSE"},
    itemSpawner = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    itemReroller = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    baseCanSlotPropagate = false,
    onActivate = function(shopEnt)
        shopEnt.shopLock = true
    end
})

