local loc = localization.localize

lp.defineSlot("lootplot.s0:slot", {
    image = "slot_basic",
    name = loc("Basic Slot"),
    triggers = {"PULSE"},

    -- change color of basic-slot to match the triggers it has
    -- TODO: Maybe we should do this for other slots too?
    onUpdateClient = function(ent)
        local hasRerollTrigger = lp.hasTrigger(ent, "REROLL")
        local hasPulseTrigger = lp.hasTrigger(ent, "PULSE")

        if hasRerollTrigger then
            if hasPulseTrigger then
                ent.image = "slot_basic_teal"
            else
                ent.image = "slot_basic_green"
            end
        end
    end,

    rarity = lp.rarities.COMMON
})

