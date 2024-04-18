

local chat = {}


if server then

local chatServ = require("server.chat")

chat.message = chatServ.message
chat.privateMessage = chatServ.privateMessage

else

local chatCl = require("client.chat")
chat.message = chatCl.message

-- can override these if we want
chat.ChatBox = require("client.ChatBox")
chat.ChatMessage = require("client.ChatMessage")

chat.constants = {
    MESSAGE_DECAY_TIME = 5, -- after X seconds, messages will start to fade.
    MESSAGE_FADE_TIME = 0.5, -- how long it takes for msgs to fade.

    CHAT_BACKGROUND_COLOR = {0,0,0,0.3},
    -- TODO: this doesnt work with multicolored messages
    CHAT_MESSAGE_COLOR = {1,1,1,1},

    MESSAGE_HISTORY_SIZE = 300 -- After this many messages, messages begin to be deleted.
}

end


local commands = require("shared.commands")

chat.handleCommand = commands.handleCommand




umg.expose("chat", chat)

return chat
