local entityActiveAnimationDuration = setmetatable({}, {__mode = "k"})

umg.on("lootplot:entityActivated", function(ent)
    if ent.activateAnimation then
        ent.image = ent.activateAnimation.activate
        entityActiveAnimationDuration[ent] = assert(ent.activateAnimation.duration)
    end
end)

umg.on("@update", function(dt)
    for ent, lastActive in pairs(entityActiveAnimationDuration) do
        lastActive = lastActive - dt

        if lastActive <= 0 then
            ent.image = ent.activateAnimation.idle
            lastActive = nil
        end

        entityActiveAnimationDuration[ent] = lastActive
    end
end)
