

local DEFAULT = "UNNAMED"

local SCALE = 1/2

local EXTRA_OY = -20

local BACKGROUND_COLOR = {0.2,0.2,0.2,0.5}


components.project("nametag", "text", function(ent)
    local nametag = ent.nametag
    return {
        scale = SCALE,
        default = DEFAULT,
        component = "controller",
        oy = nametag.oy or EXTRA_OY,
        background = BACKGROUND_COLOR
    }
end)

