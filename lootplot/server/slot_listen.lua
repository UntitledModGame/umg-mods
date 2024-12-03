umg.on("lootplot:entityTriggered", function(ent, triggerName)
    if lp.isItemEntity(ent) then
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and slotEnt.slotListen and slotEnt.slotListen.trigger == triggerName then
            local success = lp.tryActivateEntity(slotEnt)
            local sL = slotEnt.slotListen
            if success and sL.activate then
                sL.activate(slotEnt)
            end
        end
    end
end)
