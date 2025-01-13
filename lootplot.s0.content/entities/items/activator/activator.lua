
local loc = localization.localize

local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


local PULSE_TARGET = {
    type = "ITEM",
    activate = function(selfEnt, ppos, targetEnt)
        lp.tryTriggerEntity("PULSE", targetEnt)
    end
}

local PULSE_DESC = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} all {lootplot.targets:COLOR}target items.")


defItem("ukulele", "Ukulele", {
    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    basePrice = 12,
    baseMaxActivations = 4,

    shape = lp.targets.KingShape(1),

    target = PULSE_TARGET
})


defItem("sticky_ukulele", "Sticky Ukulele", {
    image = "ukulele",

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    basePrice = 8,
    baseMaxActivations = 12,

    sticky = true,

    shape = lp.targets.KingShape(1),

    target = PULSE_TARGET
})





defItem("violin", "Violin", {
    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    basePrice = 12,
    baseMaxActivations = 5,

    shape = lp.targets.RookShape(2),

    target = PULSE_TARGET
})






defItem("pipe", "Pipe", {
    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE", "REROLL"},

    activateDescription = PULSE_DESC,

    basePrice = 10,
    baseMaxActivations = 5,

    shape = lp.targets.UpShape(4),

    target = PULSE_TARGET
})



defItem("red_boxing_glove", "Red Boxing Glove", {
    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = PULSE_DESC,

    repeatActivations = true,

    basePrice = 12,
    baseMaxActivations = 5,

    shape = lp.targets.UpShape(1),

    target = PULSE_TARGET
})




defItem("ping_pong_paddle", "Ping pong paddle", {
    shape = lp.targets.KNIGHT_SHAPE,

    basePrice = 7,
    baseMaxActivations = 10,

    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("Activates item again."),

    listen = {
        trigger = "PULSE",
        activate = function(selfEnt, ppos, targetEnt)
            if lp.hasTrigger(targetEnt, "PULSE") and lp.canActivateEntity(targetEnt) then
                lp.queueWithEntity(targetEnt, function(e)
                    lp.tryActivateEntity(e)
                end)
                lp.wait(ppos, 0.1)
            end
        end
    }
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

