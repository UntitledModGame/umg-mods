

local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")
local consts = require("shared.constants")




local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.unlockAfterWins = consts.UNLOCK_AFTER_WINS.BUFFY

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defItem("golden_urn", "Golden Urn", {
    rarity = lp.rarities.EPIC,
    init = helper.rotateRandomly,

    basePrice = 14,

    listen = {
        type = "ITEM",
        trigger = "BUFF"
    },
    shape = lp.targets.UpShape(3),

    baseMaxActivations = 30,
    baseMoneyGenerated = 1,
})



defItem("pink_urn", "Pink Urn", {
    rarity = lp.rarities.RARE,
    init = helper.rotateRandomly,

    activateDescription = loc("Give {lootplot:LIFE_COLOR}+1 life{/lootplot:LIFE_COLOR} to the buffed item"),

    basePrice = 12,

    listen = {
        type = "ITEM",
        trigger = "BUFF",

        filter = function(selfEnt, ppos, targEnt)
            return true
        end,
        activate = function(selfEnt, ppos, targEnt)
            targEnt.lives = (targEnt.lives or 0) + 1
        end
    },

    shape = lp.targets.UpShape(3),

    baseMaxActivations = 30,
    basePointsGenerated = 120,
})




defItem("red_urn", "Red Urn", {
    rarity = lp.rarities.RARE,
    init = helper.rotateRandomly,

    basePrice = 11,

    listen = {
        type = "ITEM",
        trigger = "BUFF",
    },

    shape = lp.targets.UpShape(3),

    baseMaxActivations = 30,
    baseMultGenerated = 2,
})





defItem("marble_chest", "Marble Chest", {
    description = loc("{wavy}{lootplot:INFO_COLOR}HINT:{/lootplot:INFO_COLOR}{/wavy} When this item's stats are increased, {lootplot:TRIGGER_COLOR}Buff{/lootplot:TRIGGER_COLOR} is triggered"),

    triggers = {"BUFF", "UNLOCK"},

    rarity = lp.rarities.RARE,

    basePrice = 11,

    baseMaxActivations = 30,
    baseMoneyGenerated = 1,
    basePointsGenerated = 30,
})


