

--[[

File for items that give global-multipliers.

]]

local loc = localization.localize
local interp = localization.newInterpolator


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end

--[[

Red net:
When target item pulsed:
Give +0.2 mult


Red flag:
Give +mult, (somehow.)
^^^ TODO, PLAN ITEM.


----------------------------------------------------
We need more +mult items!!!
Just, some super basic ones.
----------------------------------------------------


Sponge: 
earn money equal to current multiplier. (Currently: $X)
Then, set mult to -1.


Pin:
Set mult to 1.5


Anchor:
Earn 50 points
Set mult to 1


=== SUPER GOOD IDEA: ===
Have more items that REDUCE the mult.
Items that put mult into negative,
*implicitly synergize with the above items*.



....

todo;
plan others.

...

]]




defItem("leather", "Leather", {
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,

    baseMaxActivations = 5,
    baseMultGenerated = 0.8,
    baseBonusGenerated = -5
})


--[[
Opposite of leather!
]]
defItem("red_leather", "Red Leather", {
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,

    baseMaxActivations = 5,
    baseBonusGenerated = 4,
    basePointsGenerated = -20,
})





defItem("goblet_of_blood", "Goblet of Blood", {
    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    basePrice = 12,
    baseMaxActivations = 20,
    baseMultGenerated = 1.5,
    baseMoneyGenerated = -1,
    repeatActivations = true
})






local RED_FLAG_MULT = 8
--[[
If mult < 1, add +X mult
]]
defItem("red_flag", "Red Flag", {
    triggers = {"PULSE"},

    activateDescription = loc("If {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} is less than 1, add {lootplot:POINTS_MULT_COLOR}+%{mult} multiplier", {
        mult = RED_FLAG_MULT
    }),

    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        local m = lp.getPointsMult(ent) or 10
        if m < 1 then
            lp.addPointsMult(ent, RED_FLAG_MULT)
        end
    end
})




defItem("eye_worm", "Eye Worm", {
    triggers = {"PULSE"},
    activateDescription = loc("Multiplies {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} by -1"),

    onActivate = function(ent)
        local bonus = lp.getPointsBonus(ent) or 0
        lp.setPointsBonus(ent, -bonus)
    end,

    baseMaxActivations = 1,
    baseMultGenerated = 4,
    basePrice = 9,

    rarity = lp.rarities.RARE,
})





defItem("steak_maker", "Steak Maker", {
    triggers = {"PULSE"},
    activateDescription = loc("Spawns steak items."),

    basePrice = 15,
    baseMaxActivations = 10,
    baseMultGenerated = -5,

    target = {
        type = "SLOT",
        activate = function(ent, ppos)
            lp.trySpawnItem(ppos, server.entities.raw_steak, ent.lootplotTeam)
        end
    },
    shape = lp.targets.RookShape(1),

    rarity = lp.rarities.RARE,
})





defItem("red_net", "Red Net", {
    rarity = lp.rarities.RARE,

    basePrice = 8,
    baseMaxActivations = 30,
    baseMultGenerated = 0.1,

    listen = {
        type = "ITEM",
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,
})



defItem("red_pin", "Red Pin", {
    activateDescription = loc("Set multiplier to {lootplot:POINTS_MULT_COLOR}2"),

    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 1,

    onActivate = function(ent)
        lp.setPointsMult(ent, 2)
    end
})



defItem("sponge", "Sponge", {
    triggers = {"PULSE"},

    activateDescription = loc("Earn money equal to current mult.\nThen, set {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} to 0."),

    onActivate = function(ent)
        lp.addMoney(ent, lp.getPointsMult(ent) or 0)
        lp.setPointsMult(ent, 0)
    end,

    rarity = lp.rarities.LEGENDARY,

    basePrice = 10,
    baseMaxActivations = 3,
})


do
local DEBUFF = 0.5

defItem("red_brick", "Red Brick", {
    activateDescription = loc("This item loses {lootplot:POINTS_MULT_COLOR}%{debuff} Multiplier{/lootplot:POINTS_MULT_COLOR} permanently", {
        debuff = DEBUFF
    }),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    baseMultGenerated = DEBUFF * 10,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "multGenerated", -DEBUFF)
    end
})

end



defItem("flamingo", "Flamingo", {
    triggers = {"PULSE"},
    activateDescription = loc("Adds {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} equal to the number of lives that this item has."),

    unlockAfterWins = 3,
    rarity = lp.rarities.EPIC,

    basePrice = 10,
    baseMaxActivations = 3,
    baseMultGenerated = 0,

    lives = 1,

    lootplotProperties = {
        modifiers = {
            multGenerated = function(ent)
                return ent.lives or 0
            end
        }
    }
})





defItem("red_fan", "Red Fan", {
    triggers = {"PULSE"},

    activateDescription = loc("Buff item's {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} by what the current multiplier is"),

    basePrice = 12,
    baseMaxActivations = 6,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local amount = lp.getPointsMult(selfEnt) or 0
            lp.modifierBuff(targetEnt, "pointsGenerated", amount)
        end
    },
    shape = lp.targets.UpShape(2),

    rarity = lp.rarities.LEGENDARY,
})





defItem("anchor", "Anchor", {
    activateDescription = loc("Set {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} to 1.\nSet {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} to 0."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 7,
    baseMaxActivations = 3,

    baseMoneyGenerated = 1,

    onActivate = function(ent)
        lp.setPointsMult(ent, 1)
        lp.setPointsBonus(ent, 0)
    end
})

