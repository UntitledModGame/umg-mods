


local function getAuthorizedControlEntity(authEnt)
    -- warning: this is O(n)
    local clientId = client.getClient()
    local ents = control.getControlledEntities(clientId)

    for _, ent in ipairs(ents) do
        if permissions.entityHasPermission(ent, authEnt) then
            return ent
        end
    end
end


return getAuthorizedControlEntity
