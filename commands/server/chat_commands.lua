


chat.handleCommand("run", {
    handler = function(sender, script)
        local success, err, chunk
        success, chunk = pcall(loadstring, script)
        if not success then
            chat.privateMessage(sender, "invalid syntax: /run <luaScript>")
            return
        end
    
        success, err = pcall(chunk)
        if not success then
            chat.privateMessage(sender, "error running script: " .. err)
        end
    end,

    adminLevel = 100,
    arguments = {{name = "script", type = "string"}}
})


chat.handleCommand("tickrate", {
    handler = function(sender, tickrate)
        local succ, err = pcall(server.setTickrate, tickrate)
        if not succ then
            chat.privateMessage(sender, "error setting tickrate: " .. tostring(err))
        end
    end,

    adminLevel = 100,
    arguments = {{name = "tickrate", type = "number"}}
})



local function getSenderPosition(sender)
    --[[
        Returns any entity that is being controlled by sender,
        and has x,y components
    ]]
    local ents = control.getControlledEntities(sender)
    for _, e in ipairs(ents) do
        if e.x and e.y then
            return e
        end
    end
end




chat.handleCommand("position", {
    handler = function(sender)
        local dvec = getSenderPosition(sender)
        if dvec then
            chat.privateMessage(sender, ("(%.1f, %.1f)"):format(dvec.x, dvec.y))
        else
            chat.privateMessage(sender, "You have no player entity!")
        end
    end,

    adminLevel = 0,
    arguments = {}
})



local PLAYER_SPAWN_OFFSET = 30

chat.handleCommand("spawn", {
    arguments = {
        {name = "entType", type = "string"}
    },
    adminLevel = 50,

    handler = function(sender, entType)
        if server.entities[entType] then
            local p = getSenderPosition(sender)
            local x,y = 0,0
            if not p then
                return
            end
            x,y = p.x, p.y + PLAYER_SPAWN_OFFSET
            local e = server.entities[entType](x,y)
            if p.dimension then
                e.dimension = p.dimension
            end
        else
            chat.message("SPAWN FAILED: Unknown entity type " .. tostring(entType))
        end
    end
})




local values = require("shared.values")



--[[

Think of these like getting/setting global "config" variables

]]

chat.handleCommand("set", {
    arguments = {
        {name = "key", type = "string"},
        {name = "value", type = "string"}
        -- ^^^ TODO: We should allow for setting of numbers here too
    },
    adminLevel = 50,

    handler = function(sender, key, value)
        values[key] = value
    end
})



chat.handleCommand("get", {
    arguments = {
        {name = "key", type = "string"},
    },
    adminLevel = 50,

    handler = function(sender, key)
        local msg = key .. ": " .. tostring(values[key])
        chat.privateMessage(sender, msg)
    end
})

