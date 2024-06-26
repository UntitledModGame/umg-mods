

lp.defineItem("strawberry", {
    image = "strawberry",

    name = "Strawberry",
    description = "We can do anything we want",
    buyPrice = 5,

    onActivate = function(ent)
        lp.addPoints(ent, 1)
        lp.addMoney(ent, 1)
    end
})

