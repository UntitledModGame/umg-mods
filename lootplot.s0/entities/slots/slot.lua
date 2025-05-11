local loc = localization.localize



-- change color of basic-slot to match the triggers it has
-- TODO: Maybe we should do this for other slots too?
local function onUpdateClient(ent)
    local hasRerollTrigger = lp.hasTrigger(ent, "REROLL")
    local hasPulseTrigger = lp.hasTrigger(ent, "PULSE")

    if hasRerollTrigger then
        if hasPulseTrigger then
            ent.image = "slot_basic_teal"
        else
            ent.image = "slot_basic_green"
        end
    end
end


lp.defineSlot("lootplot.s0:slot", {
    image = "slot_basic",
    name = loc("Basic Slot"),
    triggers = {"PULSE"},

    onUpdateClient = onUpdateClient,

    rarity = lp.rarities.COMMON
})





--[[
Add a few variations to make it more fun:
]]


lp.defineSlot("lootplot.s0:basic_slot_points", {
    image = "slot_basic",
    name = loc("Basic Slot"),
    triggers = {"PULSE"},

    onUpdateClient = onUpdateClient,

    basePointsGenerated = 50,
    rarity = lp.rarities.UNCOMMON
})



lp.defineSlot("lootplot.s0:basic_slot_bonus", {
    image = "slot_basic",
    name = loc("Basic Slot"),
    triggers = {"PULSE", "REROLL"},

    onUpdateClient = onUpdateClient,

    baseBonusGenerated = 5,
    rarity = lp.rarities.UNCOMMON
})



lp.defineSlot("lootplot.s0:basic_slot_money", {
    image = "slot_basic",
    name = loc("Basic Slot"),
    triggers = {"PULSE"},

    onUpdateClient = onUpdateClient,

    baseMoneyGenerated = 1,

    rarity = lp.rarities.EPIC
})

