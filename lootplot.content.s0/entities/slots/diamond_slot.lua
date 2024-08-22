
return lp.defineSlot("lootplot.content.s0:diamond_slot", {
    image = "diamond_slot",
    name = localization.localize("Diamond slot"),
    description = localization.localize("Activates three times"),
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end

        lp.queue(ppos, function ()
            local item = lp.slotToItem(ent)
            if item then
                lp.tryTriggerEntity("PULSE", item)
            end
        end)
        
        lp.queue(ppos, function ()
            local item = lp.slotToItem(ent)
            if item then
                lp.tryTriggerEntity("PULSE", item)
            end
        end)
    end
})


