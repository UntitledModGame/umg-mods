

local loc = localization.localize
local constants = require("shared.constants")



-- change color of basic-slot to match the triggers it has
-- TODO: Maybe we should do this for other slots too?
local function onUpdateClient(ent)
    local hasRerollTrigger = lp.hasTrigger(ent, "REROLL")
    local hasPulseTrigger = lp.hasTrigger(ent, "PULSE")
    local hasLevelTrigger = lp.hasTrigger(ent, "LEVEL_UP")

    if hasLevelTrigger then
        ent.image = "slot_basic_red"
    end

    if hasRerollTrigger then
        if hasPulseTrigger then
            ent.image = "slot_basic_teal"
        else
            ent.image = "slot_basic_green"
        end
    end
end


local function defBasicSlot(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or "slot_basic"
    etype.onUpdateClient = etype.onUpdateClient

    etype.baseMaxActivations = etype.baseMaxActivations or 10

    etype.onUpdateClient = onUpdateClient

    etype.lootplotTags = {constants.tags.BASIC_SLOT}

    lp.defineSlot("lootplot.s0:" .. id, etype)
end



defBasicSlot("slot", "Basic Slot", {
    triggers = {"PULSE"},
    rarity = lp.rarities.COMMON
})




--[[
Add a few variations to make it more fun:
]]


defBasicSlot("basic_slot_points", "Basic Slot", {
    triggers = {"PULSE"},
    basePointsGenerated = 50,
    rarity = lp.rarities.UNCOMMON
})



defBasicSlot("basic_slot_bonus", "Basic Slot", {
    triggers = {"PULSE", "REROLL"},
    baseBonusGenerated = 5,
    rarity = lp.rarities.UNCOMMON
})



defBasicSlot("basic_slot_money", "Basic Slot", {
    triggers = {"PULSE"},
    baseMoneyGenerated = 1,
    rarity = lp.rarities.EPIC
})

