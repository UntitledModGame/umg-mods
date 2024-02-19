
local controllableGroup = umg.group("controllable", "controller")


-- Mapping from clientId -> control ent set.
-- A set of all entities that clientId is controlling
local client_to_ents = {
--[[
    [clientId] -> Set[ent1, ent2, ...]
]]
}


-- Gotta keep backrefs so no memory leaks
-- (Since the value of `controller` could be changed at runtime, 
-- we have to keep track of it here.)
local ent_to_client = {
--[[
    [ent] -> clientId
]]
}



local function addEntity(ent)
    local cl = ent.controller
    if not cl then
        return
    end
    if not client_to_ents[cl] then
        client_to_ents[cl] = objects.Set()
    end
    client_to_ents[cl]:add(ent)
    ent_to_client[ent] = cl
end


local function removeEntity(ent, cl)
    if client_to_ents[cl] then
        client_to_ents[cl]:remove(ent)
    end
    ent_to_client[ent] = nil
end


local function updateEntity(ent)
    removeEntity(ent)
    addEntity(ent)
end



controllableGroup:onAdded(addEntity)


controllableGroup:onRemoved(removeEntity)



umg.on("@tick", function()
    for _, ent in ipairs(controllableGroup) do
        updateEntity(ent)
    end
end)


local EMPTY_SET = objects.Set()

local function getControlledEntities(clientId)
    if (not clientId) then
        assert(client, "Need to pass clientId")
        clientId = client.getClient()
    end
    return client_to_ents[clientId] or EMPTY_SET
end


return getControlledEntities
