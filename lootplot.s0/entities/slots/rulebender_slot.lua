local loc = localization.localize


return lp.defineSlot("lootplot.s0:rulebender_slot", {
    image = "rulebender_slot",
    name = loc("Rulebender slot"),
    description = loc("Item's properties are multiplied by -1 while on this slot"),
    --[[
    players can bend the rules really hard with this slot.

    An item that costs $3 to use, 
    instead EARNS $3.

    Also consider an item like red-brick:
    Instead of stealing -20 mult,
    it earns +20 mult!!!
    ]]
    baseMaxActivations = 1,
    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    slotItemProperties = {
        multipliers = {
            pointsGenerated = -1,
            bonusGenerated = -1,
            multGenerated = -1,
            moneyGenerated = -1,
        }
    },
})
