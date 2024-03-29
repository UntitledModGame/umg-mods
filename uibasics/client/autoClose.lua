

local getAuthorizedControlEntity = require("client.getAuthControlEnt")


--[[

Auto-close UIs if we no longer have permission:

]]


-- dont wanna run every frame!
local SKIPS = 60

umg.on("@update", scheduling.skip(SKIPS, function()
    local remBuffer = objects.Array()
    -- Close all UIs that we no-longer have access to.
    for _, element in ipairs(uiBasics.getOpenElements()) do
        local e = element:getEntity()
        if e and (e.authorizable) then
            local hasAuth = getAuthorizedControlEntity(e)
            if not hasAuth then
                -- If we no longer have permission,
                -- then close this UI.
                remBuffer:add(e)
            end
        end
    end

    for _,e in ipairs(remBuffer) do
        uiBasics.close(e)
    end
end))

