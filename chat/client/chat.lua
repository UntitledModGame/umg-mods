

local chat = {}


local chatControls = require("client.chatControls")

local constants = require("constants")


local lg=love.graphics




client.on("chat:message", function(msg)
    -- TODO: Do colors and stuff here.
    chatBox:pushMessage(msg)
end)



local currMessage = ""
local isTyping = false







love.keyboard.setKeyRepeat(true)


local function parseCommandArg(arg)
    if arg:lower() == "true" then
        return true
    elseif arg:lower() == "false" then
        return false
    elseif tonumber(arg) then
        return tonumber(arg)
    end
    return arg
end



local function doCommand(message)
    local buffer = {}
    local _,f = message:find("%S+")
    local command = message:sub(2, f)
    if #message > 0 then
        for arg in message:sub(f+1):gmatch("%S+") do
            table.insert(buffer, parseCommandArg(arg))
        end
        client.send("chat:command", command, unpack(buffer))
    end
end



local listener = input.InputListener({priority = 5})



listener:onTextInput(function(_self, t)
    if isTyping then
        currMessage = currMessage .. t
    end
end)




--[[
    todo:

    make a proper chat channels API and stuff, and make it consistent
]]
local DEFAULT_CHANNEL = constants.DEFAULT_CHANNEL
local COMMAND_CHAR = constants.COMMAND_CHAR

function chat.message(msg, channel)
    local startChar = msg:sub(1,1)
    if COMMAND_CHAR == startChar then
        doCommand(msg)
    else
        channel = channel or DEFAULT_CHANNEL
        client.send("chat:message", msg, channel)
    end
end



local function inputTyping(controlEnum)
    if controlEnum == chatControls.BACKSPACE then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(currMessage, -1)
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            currMessage = string.sub(currMessage, 1, byteoffset - 1)
        end
    elseif controlEnum == chatControls.CHAT then
        if #currMessage>0 then
            chat.message(currMessage)
            currMessage = ''
        end
        isTyping = false
    elseif controlEnum == "ui:EXIT" then
        isTyping = false
    end
end


local function inputNotTyping(cEnum)
    if cEnum == chatControls.CHAT or cEnum == chatControls.OPEN_COMMAND then
        -- shorthand for typing commands
        isTyping = true
    end
end


listener:onAnyPressed(function(_self, controlEnum)
    --[[
        TODO: Do we need to do blocking here???
    ]]
    if isTyping then
        inputTyping(controlEnum)
    else
        inputNotTyping(controlEnum)
    end
end)



listener:onUpdate(function(self)
    if isTyping then
        self:lockTextInput()
    end
end)



umg.on("rendering:drawUI", function()
    --[[
        draw the chat:
    ]]
    lg.push("all")
    chatBox:render(0,0,lg.getDimensions())
    if isTyping then
        drawMessage(currMessage, 1)
        drawCursor()
    end
    lg.pop()
end)



return chat
