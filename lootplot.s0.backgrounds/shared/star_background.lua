local defBG = require("shared.itemdef")
local loc = localization.localize

local constructor = nil

if client then

local StarBackground = require("client.StarBackground")

function constructor()
    return StarBackground(3)
end

end

defBG("lootplot.s0.backgrounds:star_background", {
    name = loc("Star Background"),
    description = loc("Just stars"),
    constructor = constructor
})
