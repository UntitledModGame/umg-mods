local loc = localization.localize

local constructor = nil

if client then

local StarBackground = require("client.StarBackground")

function constructor()
    return StarBackground(3)
end

end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:star_background", {
    name = loc("Star Background"),
    description = loc("Just stars"),
    constructor = constructor
})
