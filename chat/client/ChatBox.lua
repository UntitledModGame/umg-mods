

local ChatBox = ui.Element("chat:ChatBox")


local MESSAGE_DECAY_TIME = 5 -- after X seconds, messages will start to fade.
local MESSAGE_FADE_TIME = 0.5 -- how long it takes for msgs to fade.

local CHATBOX_START_X = 2
local CHATBOX_HEIGHT = 2
local MESSAGE_SEP = 10
local CHAT_WRAP_WIDTH = 300

local TARGET_CHAT_HEIGHT = 6 -- This number is actually quite arbitrary

local lg=love.graphics



function ChatBox:init()
    self.maxMessages = 20
    self.heightRatio = 0.5 
    -- should take up this percentage of the screen, vertically
end



local HEIGHT_TEST_CHARS = "abc"


local curFont = lg.getFont()
local curFontHeight = lg.getFont():getHeight(HEIGHT_TEST_CHARS)
local curHeight = CHATBOX_HEIGHT
local curChatScale = TARGET_CHAT_HEIGHT / curFontHeight

local function drawCursor()
    local cursorOpacity = (math.sin(curTime * 12) + 1) / 2
    local x = CHATBOX_START_X + curFont:getWidth(currMessage) * curChatScale
    local y = curScreenHeight - curHeight
    lg.push("all")
    local opacity = math.floor(cursorOpacity + 0.65)
    lg.setColor(0,0,0,opacity)
    lg.rectangle("fill", x, y, 4, 10)
    lg.pop()
end


local BACKDROP_SEP = 1

local function drawMessage(msg, region, opacity)
    -- TODO: Do different colors here.
    local scale = curChatScale
    local wrapWidth = CHAT_WRAP_WIDTH / scale
    local _, wrappedtxt = curFont:getWrap(msg, wrapWidth)
    local newlines = #wrappedtxt
    curHeight = curHeight + ((newlines * (curFontHeight)) + MESSAGE_SEP) * scale
    local y = curScreenHeight - curHeight
    lg.setColor(0.1,0.1,0.1,opacity)
    lg.printf(msg, CHATBOX_START_X - BACKDROP_SEP, y - BACKDROP_SEP, wrapWidth, "left", 0, scale,scale)    
    lg.setColor(1,1,1,opacity)
    lg.printf(msg, CHATBOX_START_X, y, wrapWidth, "left", 0, scale,scale)
end


local function iterMessage(messageObj, region)
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
    curFont = lg.getFont()
    curFontHeight = lg.getFont():getHeight(HEIGHT_TEST_CHARS)
    curHeight = CHATBOX_HEIGHT
    curScreenHeight = lg.getHeight()
    --[[
        TODO: Scale the chat somehow.

        Convert to a `ui` element perhaps...?
    ]]
    curChatScale = TARGET_CHAT_HEIGHT / curFontHeight

    lg.push("all")
    if isTyping then
        drawMessage(currMessage, 1)
        drawCursor()
    end

    chatHistory:foreach(iterMessage)
    lg.pop()
end)




function ChatBox:onRender(x,y,w,h)
    -- x,y,w,h should be the size of the screen
    local r,_ = ui.Region(x,y,w,h):splitVertical(self.heightRatio, 1-self.heightRatio)

    local regions = r:grid(1,self.maxMessages)

    for i=#regions,1,-1 do
        local i = 
    end
end

return ChatBox

