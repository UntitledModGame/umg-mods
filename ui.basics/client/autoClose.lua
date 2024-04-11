

local getAuthorizedControlEntity = require("client.getAuthControlEnt")


--[[

Auto-close UIs if we no longer have permission:

]]


-- dont wanna run every frame!
local SKIPS = 60

umg.on("@update", scheduling.skip(SKIPS, function()
    local remBuffer = objects.Array()
    -- Close all UIs that we no-longer have access to.
    for _, element in ipairs(ui.basics.getOpenElements()) do
        local e = element:getEntity()
        if e and (e.authorizable) then
            local hasAuth = getAuthorizedControlEntity(e)
            if not hasAuth then
                -- If we no longer have permission,
                -- then close this UI.
                remBuffer:add(element)
            end
        end
    end

    local scene = ui.basics.getScene()
    for _,e in ipairs(remBuffer) do
        scene:removeChild(e)
    end
end))

