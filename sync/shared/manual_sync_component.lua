
--[[

sync.syncComponent(ent, compName)


Manually syncs a component on serverside.
Uses string -> id compression to compress the component name.
(Doesn't care about delta compression or nils)


]]



local currentId = 0

local componentIdCache = {--[[
    [id] -> compName
    [compName] -> id

    compresses component names to ids, for easy access.
]]}


umg.definePacket("sync:syncComponent", {
    --          entity  comp_id  serialization-data
    typelist = {"entity", "number", "string"}
})

umg.definePacket("sync:setSyncComponentCache", {
    --         json-data
    typelist = {"string"}
})





if client then

client.on("sync:setSyncComponentCache", function(cacheData)
    local cache = umg.deserialize(cacheData)
    componentIdCache = cache
end)

client.on("sync:syncComponent", function(ent, id, compValue)
    local compName = componentIdCache[id]
    if compName then
        ent[compName] = compValue
    else
        print("[sync.syncComponent] WARNING: Unknown component id")
    end
end)

end





if server then

local function updateCompIdCache()
    --[[
        dear future Oli:
        pls dont hate me if there's a desync because of this
    ]]
    server.broadcast("sync:setSyncComponentCache", umg.serialize(componentIdCache))
end

umg.on("@playerJoin", function()
    -- whenever a new player joins, send over the component id cache.
    -- (Yes it's shit, but who cares)
    updateCompIdCache()
end)


local function addEntry(compName)
    currentId = currentId + 1
    local compId = currentId
    componentIdCache[compId] = compName
    componentIdCache[compName] = compId
end


local function getComponentId(compName)
    if not componentIdCache[compName] then
        addEntry(compName)
        updateCompIdCache()
    end
    return componentIdCache[compName]
end



local syncComponentTc = typecheck.assert("entity", "string")
local function syncComponent(ent, compName)
    syncComponentTc(ent, compName)

    local id = getComponentId(compName)
    server.broadcast("sync:syncComponent", ent, id, ent[compName])
end

return syncComponent

end


