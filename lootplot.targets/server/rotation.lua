

umg.on("lootplot:itemRotated", function(ent, amount)
    if ent.shape and lp.isItemEntity(ent) then
        lp.targets.setShape(ent, lp.targets.RotationShape(ent.shape, amount))
    end
end)
