local AFTER = 10000

umg.on("rendering:drawEntity", AFTER, function(ent)
    if lp.isItemEntity(ent) then
        local slotEnt = lp.itemToSlot(ent)

        if slotEnt and slotEnt.onItemDraw then
            slotEnt.onItemDraw(slotEnt, ent)
        end
    end
end)
