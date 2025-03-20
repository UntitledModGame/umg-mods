
local loc = localization.localize
local interp = localization.newInterpolator


local function defFred(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defFred("fred_sad", "Sad Fred", {
    activateDescription = loc("Gives you a billion dollars"),

    rarity = lp.rarities.UNIQUE,

    canItemFloat = true,
    repeater = true,

    scaleX = 16/128, scaleY = 16/128,

    triggers = {"PULSE"},

    shape = lp.targets.KingShape(2),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            lp.destroy(targEnt)
        end
    }
})


