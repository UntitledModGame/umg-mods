

lp.defineItem("bb", {
    image = "blueberry",

    name = "Blueberry",
    description = "Generates a point",

    onActivate = function(ent)
        lp.addPoints(ent, 1)
    end
})

