



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

    -- TODO: Do colored names here
    local msg = "[" .. sender .. "]" .. " " .. message
    server.broadcast("chat:message", msg, channel)
end)










function chat.message(message)
    local channel = message or constants.DEFAULT_CHANNEL
    server.broadcast("chat:message", message, channel)
end


function chat.privateMessage(clientId, message)
    local channel = message or constants.DEFAULT_CHANNEL
    server.unicast( clientId, "chat:message", message, channel)
end


return chat

