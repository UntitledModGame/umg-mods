

lp.defineItem("strawberry", {
    image = "strawberry",

    name = "Strawberry",
    description = "We can do anything we want",
    baseBuyPrice = 5,

    rarity = lp.rarities.COMMON,
    baseTraits = {},

    onActivate = function(ent)
        lp.addPoints(ent, 1)
        lp.addMoney(ent, 1)
    end
})

