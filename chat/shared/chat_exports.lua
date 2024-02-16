

local chat = {}


if server then

local chatServ = require("server.chat")

chat.message = chatServ.message
chat.privateMessage = chatServ.privateMessage

else

local chatCl = require("client.chat")
chat.message = chatCl.message

end


local commands = require("shared.commands")

chat.handleCommand = commands.handleCommand




umg.expose("chat", chat)

return chat
