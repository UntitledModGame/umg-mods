

local loc = localization.localize



lp.defineItem("lootplot.unlocks:key", {
    image = "key",
    name = loc("Key"),

    shape = lp.targets.RookShape(1),
    target = {
        type = lp.CONVERSIONS.ITEM_OR_SLOT,
        activate = function(_, ppos)
            local item = lp.posToItem(ppos)
            local slot = lp.posToSlot(ppos)
            if item then
                lp.tryTriggerEntity("UNLOCK", item)
            end
            if slot then
                lp.tryTriggerEntity("UNLOCK", slot)
            end
        end,
        description = loc("Triggers {lootplot:TRIGGER_COLOR}UNLOCK{lootplot:TRIGGER_COLOR} for slots and items."),
    },

    rarity = lp.rarities.UNIQUE,
})

