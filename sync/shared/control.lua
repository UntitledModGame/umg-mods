
--[[

Determines whether an entity is controllable by the client, or not.

]]



local control = {}


function control.isControlledBy(ent, clientId)
    --[[
        Checks if an entity is controllable by clientId
    ]]
    if not umg.exists(ent) then
        return
    end
    local controller = ent.controller
    local ok = controller == clientId

    if ok then
        -- check that it's not blocked
        local blocked = umg.ask("sync:isControlBlocked", ent, clientId)
        return not blocked
    end
end



if client then

local clientId = client.getClient()

function control.isClientControlling(ent)
    return control.isControlledBy(ent, clientId)
end

end


return control
