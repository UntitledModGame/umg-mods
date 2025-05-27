
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
Set bonus to 6
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
    rarity = lp.rarities.RARE,

    baseBonusGenerated = 5,
    baseMultGenerated = -0.1
})



defItem("blue_pin", "Blue Pin", {
    activateDescription = loc("Set bonus to {lootplot:BONUS_COLOR}6"),

    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 1,

    onActivate = function(ent)
        lp.setPointsBonus(ent, 6)
    end
})



do
local DEBUFF = 4

defItem("blue_brick", "Blue Brick", {
    activateDescription = loc("This item loses {lootplot:BONUS_COLOR}%{debuff} Bonus{/lootplot:BONUS_COLOR} permanently", {
        debuff = DEBUFF
    }),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    baseBonusGenerated = DEBUFF * 10,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "bonusGenerated", -DEBUFF)
    end
})

end


defItem("blue_cube", "Blue Cube", {
    rarity = lp.rarities.RARE,

    triggers = {"PULSE", "REROLL", "ROTATE"},

    basePrice = 8,
    baseMaxActivations = 20,
    basePointsGenerated = -40,
    baseBonusGenerated = 6
})





--[[
Boomerang synergizes with BONUS archetype
]]
local DIAMOND_POINT_ACTIVATION_COUNT = 15
local DIAMOND_POINTS = 1

defItem("diamond", "Diamond", {
    triggers = {"PULSE"},

    activateDescription = loc("Earns {lootplot:POINTS_COLOR}+%{points} points{/lootplot:POINTS_COLOR} %{n} times", {
        n = DIAMOND_POINT_ACTIVATION_COUNT,
        points = DIAMOND_POINTS
    }),

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if not ppos then return end

        for i=1, DIAMOND_POINT_ACTIVATION_COUNT do
            lp.wait(ppos, 0.15)
            lp.queueWithEntity(ent, function(e)
                lp.addPoints(e, DIAMOND_POINTS)
                lp.incrementCombo(e, 1)
            end)
        end
    end,

    baseMaxActivations = 8,
    basePrice = 10,

    rarity = lp.rarities.RARE,
})




defItem("fish_skeleton", "Fish Skeleton", {
    triggers = {"PULSE"},
    activateDescription = loc("Spawn free %{UNCOMMON} items on {lootplot:INFO_COLOR}dirt-slots.", {
        UNCOMMON = lp.rarities.UNCOMMON.displayString
    }),

    unlockAfterWins = 2,

    basePrice = 8,
    baseBonusGenerated = 4,

    shape = lp.targets.HorizontalShape(2),
    target = {
        type = "SLOT_NO_ITEM",
        filter = function(selfEnt, ppos, slotEnt)
            return slotEnt:type() == "lootplot.s0:dirt_slot"
        end,
        activate = function(selfEnt, ppos, slotEnt)
            local itemEType = lp.rarities.randomItemOfRarity(lp.rarities.UNCOMMON)
            if itemEType then
                lp.trySpawnItem(ppos, itemEType, selfEnt.lootplotTeam)
            end
        end
    },

    rarity = lp.rarities.RARE,
})


