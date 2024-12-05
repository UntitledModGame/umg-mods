local AFTER = 10000

umg.on("rendering:drawEntity", AFTER, function(ent, x,y, rot, sx,sy)
    if lp.isItemEntity(ent) then
        local slotEnt = lp.itemToSlot(ent)

        if slotEnt and slotEnt.onItemDraw then
            slotEnt:onItemDraw(ent, x,y, rot, sx,sy)
        end
    end
end)
