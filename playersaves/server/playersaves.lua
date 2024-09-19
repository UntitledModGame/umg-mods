

-- Group of entities that are being controlled by players.
local control_ents = umg.group("controllable", "controller")




local EXTEN = ".playersaves_data"



local function get_filename(clientId)
    return clientId .. EXTEN
    -- Just some arbitrary extension so it's identifiable, and so
    -- that there are no filename collisions.
end



local function load_data(clientId, entity_data)
    if entity_data then
        local res, err = umg.deserialize(entity_data)
        if ((not res) and err) then
            print("[playersaves]: couldn't deserialize player: ", err)
            umg.call("playersaves:createPlayer", clientId)
        end
    else
        -- Welp, this player has no savedata!
        -- A newPlayer event is emitted, and a player should be created
        -- from that event somewhere.
        umg.call("playersaves:createPlayer", clientId)
    end   
end



umg.on("@playerJoin", function(clientId)
    -- load from file
    local fname = get_filename(clientId)
    local entity_data = umg.melt("TODO: use save API to load stuff here")
    load_data(entity_data)
end)



local function save_data(clientId, entity_data)
    -- world is persistent, so save to file
    local fname = get_filename(clientId)
    umg.melt("TODO: use save API to save stuff here")
end



umg.on("@playerLeave", function(clientId)
    local buffer = {}
    for i=1, #control_ents do
        local ent = control_ents[i]
        if ent.controller == clientId then
            table.insert(buffer, ent)
        end
    end

    if #buffer > 0 then
        local entity_data = umg.serialize(buffer)
        --[[
            The reason we can serialize the buffer here, instead of each entity,
            is because when entities are deserialized, they are automatically put
            into systems.
            And since serialization / deserialization is done recursively, it
            doesn't matter that they are in a table- they will still be reached.
        ]]

        for i=1, #buffer do
            -- now delete all entities in the buffer
            buffer[i]:delete()
        end

        save_data(clientId, entity_data)
    end
end)


