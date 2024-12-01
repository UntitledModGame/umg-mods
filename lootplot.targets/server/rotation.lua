

umg.on("lootplot:itemRotated", function(ent, amount)
    umg.melt("set the shape here!")
    --[[
    todo: we also gotta add juice and sfx too
    ]]
    if ent.shape and lp.isItemEntity(ent) then
        lp.targets.setShape(ent, lp.targets.RotationShape(ent.shape, amount))
    end
end)
