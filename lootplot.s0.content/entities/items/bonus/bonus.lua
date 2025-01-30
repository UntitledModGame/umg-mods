

--[[

Items that interact with BONUS mechanism



TODO!
]]


local loc = localization.localize
local interp = localization.newInterpolator


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



defItem("morning_star", "Morning Star", {
    baseBonusGenerated = 3,
    baseMultGenerated = -0.1
})

