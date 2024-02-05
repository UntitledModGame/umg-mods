
local ClientContext = require("server.client_context")




umg.on("@playerJoin", function(clientId)
    -- Send etypes over so the client knows about them
    server.unicast(clientId, "worldeditorSetEntityTypes", server.entities)
end)



local editors = {--[[
    [clientId] --> ClientContext
]]}


local sf = sync.filters

local REQUIRED_ADMIN_LEVEL = 100

local function isAdmin(sender)
    return chat.getAdminLevel(sender) > REQUIRED_ADMIN_LEVEL
end

local function isValidTool(tool)
    if sf.table(tool) then
        -- todo: Do better checks here!
        return true
    end
    return false
end




server.on("worldeditor:defineTool", function(sender, tool, toolName)
    if not isAdmin(sender) then
        return
    end

    editors[sender] = editors[sender] or ClientContext(sender)
    local cc = editors[sender]
    cc:defineTool(tool, toolName)
end)


server.on("worldeditor:setTool", function(sender, toolName)
    if not isAdmin(sender) then
        return
    end

    editors[sender] = editors[sender] or ClientContext(sender)
    local cc = editors[sender]
    cc:setCurrentTool(toolName)
end)


server.on("worldeditor:useTool", function(sender, toolName, ...)
    if not isAdmin(sender) then
        return
    end

    editors[sender] = editors[sender] or ClientContext(sender)
    local cc = editors[sender]
    local tool = cc:getCurrentTool(toolName)
    if tool then
        tool:apply(...)
    else
        chat.privateMessage(sender, "Couldn't find tool " .. toolName)
        end
end)

