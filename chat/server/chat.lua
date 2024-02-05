



--[[
    serverside chat api
]]
local chat = {}






--[[

TODO: Rate limit the number of messages that can be sent
per user, to prevent spamming.

]]

local constants = require("constants")



-- start of command character in minecraft, like `/` in minecraft.
local commandCharString = "/!;?$"
local commandChars = {}

for i=1, #commandCharString do
    commandChars[commandCharString:sub(i,i)] = true
end



server.on("chat:message", function(sender, message, channel)
    if type(message)~="string"then
        return
    end
    if #message > constants.MAX_MESSAGE_SIZE then
        return
    end
    if commandChars[message:sub(1,1)] then
        return  -- nope!
    end
    if not channel then
        -- TODO: Do colored names here
        local msg = "[" .. sender .. "]" .. " " .. message
        server.broadcast("chat:message", msg)
    else
        print("TODO: Do chat message channels")
    end
end)











local DEFAULT_ADMIN_LEVEL = 0


local ADMIN_LEVELS = {}

ADMIN_LEVELS[server.getHostClient()] = math.huge


function chat.getAdminLevel(clientId)
    return ADMIN_LEVELS[clientId] or DEFAULT_ADMIN_LEVEL
end

local setAdminLevelAssert = typecheck.assert("string", "number")
function chat.setAdminLevel(clientId, level)
    setAdminLevelAssert(clientId, level)
    ADMIN_LEVELS[clientId] = level
end



function chat.message(message)
    server.broadcast("chat:message", message)
end


function chat.privateMessage(clientId, message)
    server.unicast( clientId, "chat:message", message)
end


return chat

