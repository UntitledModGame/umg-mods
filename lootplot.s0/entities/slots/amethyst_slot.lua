local loc = localization.localize


return lp.defineSlot("lootplot.s0:amethyst_slot", {
    image = "amethyst_slot",
    name = loc("Amethyst slot"),
    description = loc("TODO: Not sure what this will do."),
    baseMaxActivations = 1,
    triggers = {"PULSE"},
    baseCanSlotPropagate = false,

    transformTo = "lootplot.s0:slot",

    -- TODO: Use slot listener? Eh this will do for now.
    onActivate = function(self)
        --[[
        TODO: do something for this slot
        ]]
    end
})
