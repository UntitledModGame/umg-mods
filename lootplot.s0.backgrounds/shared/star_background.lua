local loc = localization.localize

local constructor = nil

if client then

local StarBackground = require("client.StarBackground")

function constructor()
    return StarBackground(3)
end

end


local R,G,B = 18, 0, 33
local COLOR = {R/255, G/255, B/255}

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:star_background", {
    name = loc("Star Background"),
    description = loc("Just stars"),
    constructor = constructor,
    icon = "star_background",
    fogColor = COLOR,
})
