
--[[

Determines whether an entity is controllable by the client, or not.

]]



local control = {}



function control.getController(ent)
    --[[
        returns the controlling clientId for `ent`,
        (or nil if there is none.)
    ]]

    if not ent.controllable then
        return nil -- Not controllable, so return nil.
        -- The reason we must do this check is for efficiency reasons.
        -- autoSyncComponent in the sync mod will (indirectly) trigger
        -- this function call once for EVERY packet being synced...
        -- so we need this func to be fast.
        -- We can't afford doing a `umg.ask` for every fakken packet!!
    end

    if ent.controller then
        -- trivial case
        return ent.controller
    end

    return umg.ask("sync:getController", ent)
end



local getController = control.getController

function control.isControlledBy(ent, clientId)
    --[[
        Checks if an entity is controllable by clientId
    ]]
    if not umg.exists(ent) then
        return
    end
    local controller = getController(ent)
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
