
local loc = localization.localize

local helper = require("shared.helper")
local constants = require("shared.constants")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end


local PULSE_TARGET = {
    type = "ITEM",
    filter = function(selfEnt, ppos, targetEnt)
        return lp.hasTrigger(targetEnt, "PULSE")
    end,
    activate = function(selfEnt, ppos, targetEnt)
        lp.tryTriggerEntity("PULSE", targetEnt)
    end
}

local PULSE_DESC = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items.")


defItem("wooden_shield", "Wooden Sheild II", {
    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    basePrice = 12,
    baseMaxActivations = 4,

    shape = lp.targets.KingShape(1),

    target = PULSE_TARGET
})




defItem("wooden_shield_cost", "Wooden Shield I", {
    image = "wooden_shield",
    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    basePrice = 4,
    baseMaxActivations = 5,
    baseMoneyGenerated = -1,

    shape = lp.targets.KingShape(1),

    target = PULSE_TARGET
})




defItem("level_shield", "Level Shield", {
    rarity = lp.rarities.RARE,
    unlockAfterWins = constants.UNLOCK_AFTER_WINS.SKIP_LEVEL,

    triggers = {"LEVEL_UP"},

    activateDescription = PULSE_DESC,

    basePrice = 9,
    baseMaxActivations = 6,

    shape = lp.targets.KingShape(2),

    target = PULSE_TARGET
})





defItem("pipe", "Pipe", {
    init = helper.rotateRandomly,

    unlockAfterWins = 1,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE", "REROLL"},

    activateDescription = PULSE_DESC,

    basePrice = 8,
    baseMaxActivations = 5,
    baseBonusGenerated = -1,

    shape = lp.targets.UpShape(4),

    target = PULSE_TARGET
})



defItem("red_boxing_glove", "Red Boxing Glove", {
    init = helper.rotateRandomly,

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    repeatActivations = true,

    basePrice = 12,
    baseMaxActivations = 5,

    shape = lp.targets.UpShape(1),

    target = PULSE_TARGET
})





defItem("leather_boots", "Leather Boots", {
    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = loc("Activates slots."),

    basePrice = 8,
    baseMaxActivations = 5,

    shape = lp.targets.KingShape(1),

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return (not targEnt.buttonSlot)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryActivateEntity(targetEnt)
        end
    }
})


defItem("green_boots", "Green Boots", {
    rarity = lp.rarities.RARE,
    triggers = {"REROLL"},

    activateDescription = loc("Activates slots."),

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.REROLL,

    basePrice = 8,
    baseMaxActivations = 10,

    shape = lp.targets.KingShape(1),

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return (not targEnt.buttonSlot)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryActivateEntity(targetEnt)
        end
    }
})






defItem("ping_pong_paddle", "Ping pong paddle", {
    triggers = {"PULSE"},

    shape = lp.targets.UpShape(1),

    basePrice = 7,
    baseMaxActivations = 1,

    rarity = lp.rarities.RARE,
    unlockAfterWins = 2,

    activateDescription = loc("Gives items {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR}, but makes it {lootplot:INFO_COLOR}STUCK."),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.repeatActivations = true
            targetEnt.sticky = true
            targetEnt.stuck = true
        end
    }
})




defItem("ruby", "Ruby", {
    activateDescription = loc("Gives {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} to items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 12,
    baseMaxActivations = 1,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.repeatActivations = true
            sync.syncComponent(targetEnt, "repeatActivations")
        end
    }
})




helper.defineDelayItem("ruby_bar", "Ruby Bar", {
    basePrice = 6,

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    baseMaxActivations = 5,
    basePointsGenerated = 4,
    delayCount = 15,

    delayDescription = "Give {lootplot:REPEATER_COLOR}repeater{/lootplot:REPEATER_COLOR} to items/slots",

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM_OR_SLOT"
    },

    delayAction = function(selfEnt)
        local items = lp.targets.getConvertedTargets(selfEnt)
        for _, item in ipairs(items) do
            item.repeatActivations = true
            sync.syncComponent(item, "repeatActivations")
        end
        lp.destroy(selfEnt)
    end
})



--[[


-- OLD OCTOPUS DEFINITIONS:


defineOcto("pink_octopus", {
    name = loc("Pink Octopus"),

    target = {
        type = "ITEM",
        description = loc("{lootplot:TRIGGER_COLOR}{wavy}PULSES{/wavy}{/lootplot:TRIGGER_COLOR} item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})


defineOcto("green_octopus", {
    name = loc("Green Octopus"),

    triggers = {"REROLL", "PULSE"},

    target = {
        type = "ITEM",
        description = loc("Triggers {lootplot:TRIGGER_COLOR}{wavy}REROLL{/wavy}{/lootplot:TRIGGER_COLOR} on item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    }
})

]]

