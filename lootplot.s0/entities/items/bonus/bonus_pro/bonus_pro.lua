
--[[

BONUS-PRO:

----------

Items that work well with high-bonus,
Or items that INCREASE bonus.

----------


NOTE:
ruby-items, (and any multiple-activation item), automatically
synergizes REALLY well with bonus.



=====================
ITEM IDEAS
=====================

Blue pin:
Set bonus to 8
(^^^ same as red pin, but for bonus)

Bonus capsule:
Lose 40 points
Add 4 bonus


ITEM: 
Loses 1 point.
(repeatActivations = true)
(has 40 activations!) 



]]


local loc = localization.localize
local interp = localization.newInterpolator


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defItem("morning_star", "Morning Star", {
    baseBonusGenerated = 5,
    baseMultGenerated = -0.1
})


