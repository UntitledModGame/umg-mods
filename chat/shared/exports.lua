---@meta

---Availability: Client and Server
---@class chat.mod
local chat = {}
if false then
    _G.chat = chat
end


if server then

local chatServ = require("server.chat")

---Send message to everyone.
---
---Availability: Client and Server
---@param message string
---@param channel string?
function chat.message(message, channel)
    return chatServ.message(message, channel)
end

---Send message to single user.
---
---Availability: **Server**
---@param clientId string
---@param message string
---@param channel string?
function chat.privateMessage(clientId, message, channel)
    return chatServ.privateMessage(clientId, message, channel)
end

else

local chatCl = require("client.chat")

---Send message to everyone.
---
---Availability: Client and Server
---@param message string
---@param channel string?
function chat.message(message, channel)
    return chatCl.message(message, channel)
end

-- can override these if we want

---The chatbox class.
---
---Availability: **Client**
---@type chat.ChatBox
chat.ChatBox = require("client.ChatBox")

---The chat message class.
---
---Availability: **Client**
---@type chat.ChatMessage
chat.ChatMessage = require("client.ChatMessage")

---Availability: **Client**
chat.constants = {
    MESSAGE_DECAY_TIME = 5, -- after X seconds, messages will start to fade.
    MESSAGE_FADE_TIME = 0.5, -- how long it takes for msgs to fade.

    CHAT_BACKGROUND_COLOR = {0,0,0,0.3},
    -- TODO: this doesnt work with multicolored messages
    CHAT_MESSAGE_COLOR = {1,1,1,1},

    MESSAGE_HISTORY_SIZE = 300 -- After this many messages, messages begin to be deleted.
}

---Get chat input listener.
---
---Availability: **Client**
---@return input.InputListener
function chat.getListener()
    return chatCl.listener
end

end


local commands = require("shared.commands")

---@class chat.CommandHandler
---@field public arguments {name:string,type:string}[]
---@field public adminLevel integer
---@field public handler fun(clientId:string,...:any)

---@param commandName string
---@param handler chat.CommandHandler
function chat.handleCommand(commandName, handler)
    return commands.handleCommand(commandName, handler)
end




umg.expose("chat", chat)

return chat
