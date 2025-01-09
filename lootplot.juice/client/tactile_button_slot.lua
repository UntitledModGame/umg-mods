umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.buttonSlot then
        -- Spawn crosshair image
        local newEnt = client.entities.empty()
        newEnt.x, newEnt.y = ent.x, ent.y
        newEnt.dimension = ent.dimension
        newEnt.lifetime = 0.2
        -- ^^^ delete self after X seconds
        newEnt.image = "button_slot_click_visual"
        newEnt.drawDepth = 100
    end
end)
