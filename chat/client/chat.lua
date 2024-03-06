


local chat = {}


local LinkedList = require("_libs.doubly_linked_list")

local chatControls = require("client.chatControls")


local constants = require("constants")


local MAX_CHATHISTORY_SIZE = 300 -- After this many messages, messages begin to be deleted.

local MESSAGE_DECAY_TIME = 5 -- after X seconds, messages will start to fade.
local MESSAGE_FADE_TIME = 0.5 -- how long it takes for msgs to fade.

local CHATBOX_START_X = 2
local CHATBOX_HEIGHT = 2
local MESSAGE_SEP = 10
local CHAT_WRAP_WIDTH = 300

local TARGET_CHAT_HEIGHT = 6 -- This number is actually quite arbitrary





local chatHistory = LinkedList.new()


local function newMessageObject(msg)
    return {
        message = msg;
        time = love.timer.getTime()
    }
end



client.on("chat:message", function(msg)
    -- TODO: Do colors and stuff here.
    chatHistory:pushf(newMessageObject(msg))
    if chatHistory:count() >= MAX_CHATHISTORY_SIZE then
        chatHistory:popl()
    end
end)




local HEIGHT_TEST_CHARS = "abc"


local curFont = love.graphics.getFont()
local curFontHeight = love.graphics.getFont():getHeight(HEIGHT_TEST_CHARS)
local curTime = love.timer.getTime()
local curHeight = CHATBOX_HEIGHT
local curScreenHeight = love.graphics.getHeight()
local curChatScale = TARGET_CHAT_HEIGHT / curFontHeight


local currMessage = ""
local isTyping = false


local function drawCursor(opacity)
    local x = CHATBOX_START_X + curFont:getWidth(currMessage) * curChatScale
    local y = curScreenHeight - curHeight
    love.graphics.push("all")
    opacity = math.floor(opacity + 0.65)
    love.graphics.setColor(0,0,0,opacity)
    love.graphics.rectangle("fill", x, y, 4, 10)
    love.graphics.pop()
end


local BACKDROP_SEP = 1

local function drawMessage(msg, opacity)
    -- TODO: Do different colors here.
    local scale = curChatScale
    local wrapWidth = CHAT_WRAP_WIDTH / scale
    local _, wrappedtxt = curFont:getWrap(msg, wrapWidth)
    local newlines = #wrappedtxt
    curHeight = curHeight + ((newlines * (curFontHeight)) + MESSAGE_SEP) * scale
    local y = curScreenHeight - curHeight
    love.graphics.setColor(0.1,0.1,0.1,opacity)
    love.graphics.printf(msg, CHATBOX_START_X - BACKDROP_SEP, y - BACKDROP_SEP, wrapWidth, "left", 0, scale,scale)    
    love.graphics.setColor(1,1,1,opacity)
    love.graphics.printf(msg, CHATBOX_START_X, y, wrapWidth, "left", 0, scale,scale)
end


local function iterMessage(messageObj)
    local dt = curTime - messageObj.time
    if dt > MESSAGE_DECAY_TIME then
        if dt > (MESSAGE_DECAY_TIME + MESSAGE_FADE_TIME) then
            return false -- no more messages to be drawn.
            -- break iteration.
        else
            -- this message is fading:
            drawMessage(messageObj.message, 1-(dt-MESSAGE_DECAY_TIME)/MESSAGE_FADE_TIME)
            return true -- continue iter
        end
    else -- draw message at full opacity
        drawMessage(messageObj.message, 1)
        return true -- continue iter
    end
end




umg.on("rendering:drawUI", function()
    --[[
        draw the chat:
    ]]
    curTime = love.timer.getTime()
    curFont = love.graphics.getFont()
    curFontHeight = love.graphics.getFont():getHeight(HEIGHT_TEST_CHARS)
    curHeight = CHATBOX_HEIGHT
    curScreenHeight = love.graphics.getHeight()
    --[[
        TODO: Scale the chat somehow.

        Convert to a `ui` element perhaps...?
    ]]
    curChatScale = TARGET_CHAT_HEIGHT / curFontHeight

    love.graphics.push("all")
    if isTyping then
        local opacity = (math.sin(curTime * 12) + 1) / 2
        drawMessage(currMessage, 1)
        drawCursor(opacity)
    end

    chatHistory:foreach(iterMessage)
    love.graphics.pop()
end)





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



listener:onTextInput(function(t)
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
        isTyping = not isTyping
    elseif controlEnum == "ui:EXIT" then
        isTyping = false
    end
end


local function inputNotTyping(controlEnum)
    if controlEnum == chatControls.CHAT then
        if isTyping then
            if #currMessage>0 then
                chat.message(currMessage)
                currMessage = ''
            end
        end
        isTyping = not isTyping
    elseif controlEnum == chatControls.OPEN_COMMAND then
        -- shorthand for typing commands
        if not isTyping then
            isTyping = true
        end
    end
end


listener:onAnyPress(function(_self, controlEnum)
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



return chat
