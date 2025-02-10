

local loc = localization.localize

lp.defineSlot("lootplot.s0:swashbuckler_slot", {
    image = "swashbuckler_slot",
    name = loc("Swashbuckler Slot"),

    triggers = {"PULSE"},
    activateDescription = loc("Items placed on this slot don't cost any money to activate.\n(And cannot earn money!)"),

    rarity = lp.rarities.EPIC,

    slotItemProperties = {
        multipliers = {
            moneyGenerated = 0
        }
    },
})


