
return lp.defineSlot("lootplot.content.s0:diamond_slot", {
    image = "diamond_slot",
    name = localization.localize("Diamond slot"),
    baseMaxActivations = 3,
    description = localization.localize("Activates items three times"),
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not (ppos) then return end
        lp.queue(ppos, function()
            local item = lp.slotToItem(ent)
            if item then
                lp.tryActivateEntity(item)
            end
        end)

        lp.queue(ppos, function()
            local item = lp.slotToItem(ent)
            if item then
                lp.tryActivateEntity(item)
            end
        end)
    end
})

