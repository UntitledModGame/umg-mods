local loc = localization.localize

return lp.defineSlot("lootplot.s0:null_slot", {
    triggers = {"PULSE"},
    image = "null_slot",
    name = loc("Null slot"),
    rarity = lp.rarities.COMMON,
    description = loc("Items are not activated in this slot!"),

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,
})
