lp.defineItem("kiwi", {
    image = "kiwi",

    name = "Kiwi",
    description = "https://www.youtube.com/watch?v=Qk4KcP1VGIc",
    baseBuyPrice = 5,

    targetShape = lp.targets.ROOK_SHAPE,

    onActivate = function(ent)
        lp.addPoints(ent, 1)
        lp.addMoney(ent, 1)
    end,

    targetType = "ITEM",
    activateTargets = function(ent, ppos, targetEnt)
        print("🥝🥝🥝 kiwi tongue needle activator 🥝🥝🥝", ent, ppos, targetEnt)
    end,
})

