
local loc = localization.localize
local interp = localization.newInterpolator

--[[


Clone rocks: 
Transform into target rocks


Anti-bonus rocks {
    [divides bonus by 2]

    rock (+PULSE): earns 50 pts 
    rock (+REROLL): earns 50 pts
}


Orange rock (+ROTATE):  Earn $0.5, give +50 points



Pro bonus rocks {
    ICE-CUBE: +10 bonus
    diamond: (+PULSE) generates +5 points 10 times
    emerald: (+PULSE) generates +5 points 10 times
}


Grubby rocks, +mult, +points, GRUB-10


Golden rocks: Earns points equal to current balance. +1 mult


Void-rock (+UNLOCK, LEVEL_UP)
(^^^ TODO: Come up with a cool idea for this)


]]

local function defRocks(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.baseMaxActivations = 8
    etype.basePrice = 7 -- standard price for rocks

    if not etype.listen then
        etype.triggers = etype.triggers or {"DESTROY"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defRocks("clone_rocks", "Clone Rocks", {
    triggers = {"PULSE"},

    activateDescription = loc("If item has {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger, transform into a clone of it."),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 8,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "DESTROY") and targetEnt:type() ~= selfEnt:type()
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if selfPos then
                lp.forceCloneItem(targetEnt, selfPos)
            end
        end
    }
})




--[[
===================================================
Anti-bonus sub-archetype:
===================================================
]]
do
local HALF_BONUS_DESC = loc("Halves the current {lootplot:BONUS_COLOR}Bonus")
local function halfBonus(ent)
    local bonus = lp.getPointsBonus(ent) or 0
    lp.setPointsBonus(ent, bonus/2)
end

defRocks("jagged_rock", "Jagged Rock", {
    triggers = {"DESTROY", "PULSE"},

    activateDescription = HALF_BONUS_DESC,
    onActivate = halfBonus,

    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,

    lives = 300
})


defRocks("jagged_emerald", "Jagged Emerald", {
    triggers = {"DESTROY", "REROLL"},

    activateDescription = HALF_BONUS_DESC,
    onActivate = halfBonus,

    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,

    lives = 300
})
end





--[[
===================================================
Pro-bonus sub-archetype:
===================================================
]]
defRocks("ice_cube", "Ice Cube", {
    triggers = {"DESTROY"},
    rarity = lp.rarities.RARE,

    baseBonusGenerated = 15,

    lives = 80
})





defRocks("red_rock", "Red Rock", {
    triggers = {"DESTROY"},
    rarity = lp.rarities.RARE,

    baseMultGenerated = 3,

    lives = 80
})






--[[
===================================================
Reroll rocks:
===================================================
]]
defRocks("orange_rock", "Orange Rock", {
    triggers = {"DESTROY", "ROTATE"},
    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,
    baseMoneyGenerated = 0.5,

    lives = 120
})



----------------------------
-- GRUBBY sub-archetype:
----------------------------
local consts = require("shared.constants")

defRocks("grubby_rock", "Grubby Rock", {
    triggers = {"DESTROY"},
    rarity = lp.rarities.RARE,

    grubMoneyCap = consts.DEFAULT_GRUB_MONEY_CAP,

    basePointsGenerated = 100,
    baseMultGenerated = 1.2,

    lives = 120
})



----------------------------
-- GOLDSMITH sub-archetype:
----------------------------
