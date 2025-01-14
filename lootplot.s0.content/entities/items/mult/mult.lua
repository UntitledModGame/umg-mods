

--[[

File for items that give global-multipliers.

]]

local loc = localization.localize
local interp = localization.newInterpolator


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
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

    basePrice = 4,

    baseMaxActivations = 5,
    baseMultGenerated = -0.1,
    basePointsGenerated = 30

})



--[[
Opposite of leather!
]]
defItem("red_leather", "Red Leather", {
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 4,

    baseMaxActivations = 5,
    baseMultGenerated = 0.5,
    basePointsGenerated = -20
})




defItem("eye_worm", "Eye Worm", {
    triggers = {"PULSE"},
    activateDescription = loc("Multiplies points by -1"),

    onActivate = function(ent)
        local pts = lp.getPoints(ent) or 0
        lp.setPoints(ent, -pts)
    end,

    baseMaxActivations = 1,
    baseMultGenerated = 5,
    basePrice = 9,
    sticky = true,

    rarity = lp.rarities.RARE,
})





defItem("steak_maker", "Steak Maker", {
    triggers = {"PULSE"},
    activateDescription = loc("Spawns steak items."),

    basePrice = 15,
    baseMaxActivations = 10,
    baseMultGenerated = -15,

    target = {
        type = "SLOT",
        activate = function(ent, ppos)
            lp.trySpawnItem(ppos, server.entities.raw_steak, ent.lootplotTeam)
        end
    },
    shape = lp.targets.UpShape(3),

    rarity = lp.rarities.RARE,
})





defItem("red_net", "Red Net", {
    rarity = lp.rarities.RARE,

    basePrice = 5,
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

    basePrice = 3,
    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.setPointsMult(ent, 1.5)
    end
})



defItem("sponge", "Sponge", {
    triggers = {"PULSE"},

    activateDescription = loc("Earn money equal to current mult.\nThen, set mult to -1."),

    onActivate = function(ent)
        lp.addMoney(ent, lp.getPointsMult(ent) or 0)
        lp.setPointsMult(ent, -1)
    end,

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    baseMaxActivations = 3,
})




defItem("red_fan", "Red Fan", {
    triggers = {"PULSE"},

    activateDescription = loc("Buff target items points-earned by the current multiplier"),

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



local ANVIL_BUFF = 6
local ANVIL_MULT_REDUCE = 0.5
defItem("anvil", "Anvil", {
    triggers = {"PULSE"},

    activateDescription = loc("Buff each target's points-earned by %{buff}.\nReduce multiplier by %{reduce} for every item that was buffed.", {
        reduce = ANVIL_MULT_REDUCE,
        buff = ANVIL_BUFF
    }),

    basePrice = 12,
    baseMaxActivations = 6,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", ANVIL_BUFF)
            lp.addPointsMult(selfEnt, -ANVIL_MULT_REDUCE)
        end
    },
    shape = lp.targets.HorizontalShape(3),

    rarity = lp.rarities.RARE,
})





defItem("anchor", "Anchor", {
    activateDescription = loc("Set {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} to 1"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 7,
    baseMaxActivations = 3,
    basePointsGenerated = 60,

    onActivate = function(ent)
        lp.setPointsMult(ent, 0)
    end
})

