umg.on("lootplot:entityTriggered", function(ent, triggerName)
    if lp.isItemEntity(ent) then
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and slotEnt.slotListen and slotEnt.slotListen.trigger == triggerName then
            lp.tryActivateEntity(slotEnt)
        end
    end
end)
