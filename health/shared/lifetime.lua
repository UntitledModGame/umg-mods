
--[[

    lifetime component.

    Gives entities a max time to be alive.

    Great for temporary entities, such as bullets, fog effects,
    entity particles, etc.

]]



-- make sure component is synced to clients.
sync.autoSyncComponent("lifetime", {
    type = "number",
    lerp = true
})






local lifetimeGroup = umg.group("lifetime")

local kill = require("shared.kill")


umg.on("@update", function(dt)
    for _, ent in ipairs(lifetimeGroup) do
        if ent:isOwned() then
            ent.lifetime = ent.lifetime - dt

            if ent.lifetime <= 0 then
                kill(ent)
            end
        end
    end
end)


