

lp.defineItem("bb", {
    image = "blueberry",

    name = "Blueberry",
    description = "Generates a point",

    rarity = lp.rarities.COMMON,
    baseTraits = {},

    onActivate = function(ent)
        lp.addPoints(ent, 1)
        lp.addMoney(ent, 1)
    end
})

