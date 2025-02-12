

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



--[[
Leather's "purpose" is to give intuition about the `global-mult` system.
]]
defItem("leather", "Leather", {
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,

    baseMaxActivations = 5,
    baseMultGenerated = -0.1,
    basePointsGenerated = 30

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



--[[
Opposite of leather!
]]
defItem("red_leather", "Red Leather", {
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,

    baseMaxActivations = 5,
    baseMultGenerated = 0.5,
    basePointsGenerated = -20
})




defItem("eye_worm", "Eye Worm", {
    triggers = {"PULSE"},
    activateDescription = loc("Multiplies bonus by -1"),

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
    baseMaxActivations = 10,
    baseMultGenerated = 0.1,

    listen = {
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,
})



defItem("red_pin", "Red Pin", {
    activateDescription = loc("Set multiplier to {lootplot:POINTS_MULT_COLOR}1.5"),

    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.setPointsMult(ent, 1.5)
    end
})



defItem("sponge", "Sponge", {
    triggers = {"PULSE"},

    activateDescription = loc("Earn money equal to current mult.\nThen, set {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} to 0."),

    onActivate = function(ent)
        lp.addMoney(ent, lp.getPointsMult(ent) or 0)
        lp.setPointsMult(ent, 0)
    end,

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    baseMaxActivations = 3,
})



defItem("red_brick", "Red Brick", {
    activateDescription = loc("This item loses {lootplot:POINTS_MULT_COLOR}0.2 Multiplier{/lootplot:POINTS_MULT_COLOR} permanently"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    baseMultGenerated = 4,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "multGenerated", -0.2)
    end
})




defItem("flamingo", "Flamingo", {
    triggers = {"PULSE"},
    activateDescription = loc("Adds {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} equal to the number of lives that this item has."),

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

    activateDescription = loc("Buff items points by the current multiplier"),

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

    rarity = lp.rarities.RARE,
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

