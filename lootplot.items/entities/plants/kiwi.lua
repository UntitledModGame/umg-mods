lp.defineItem("kiwi", {
    image = "kiwi",

    name = "Kiwi",
    description = "https://www.youtube.com/watch?v=Qk4KcP1VGIc",
    baseBuyPrice = 5,
    shape = lp.shape.KING,

    onActivate = function(ent)
        lp.addPoints(ent, 1)
        lp.addMoney(ent, 1)
    end
})

