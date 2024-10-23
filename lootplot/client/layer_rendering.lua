local AFTER = 10000

umg.on("rendering:drawEntity", AFTER, function(ent)
    if lp.isItemEntity(ent) then
        local shopEnt = lp.itemToSlot(ent)

        if shopEnt and shopEnt.onItemDraw then
            shopEnt.onItemDraw(shopEnt, ent)
        end
    end
end)
