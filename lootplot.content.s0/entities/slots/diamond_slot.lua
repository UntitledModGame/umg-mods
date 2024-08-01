
return lp.defineSlot("lootplot.content.s0:diamond_slot", {
    image = "diamond_slot",
    name = localization.localize("Diamond slot"),
    description = localization.localize("Activates items twice"),
    onActivate = function(ent)
        local item = lp.slotToItem(ent)
        if item then
            lp.tryTriggerEntity("PULSE", ent)
        end
    end
})


