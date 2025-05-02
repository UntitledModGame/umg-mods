local entityActiveAnimationDuration = setmetatable({}, {__mode = "k"})

umg.on("lootplot:entityActivated", function(ent)
    if ent.activateAnimation then
        ent.image = ent.activateAnimation.activate
        entityActiveAnimationDuration[ent] = assert(ent.activateAnimation.duration)
    end
end)


local activateAnimationGroup = umg.group("activateAnimation")

umg.on("@update", function(dt)
    for _, ent in ipairs(activateAnimationGroup) do
        local lastActive = entityActiveAnimationDuration[ent]
        if lastActive then
            lastActive = lastActive - dt

            if lastActive <= 0 then
                ent.image = ent.activateAnimation.idle
                lastActive = nil
            end

            entityActiveAnimationDuration[ent] = lastActive
        else
            ent.image = ent.activateAnimation.idle
        end
    end
end)

