
---@class chat.ChatMessage: Element
local ChatMessage = ui.Element("chat:ChatMessage")

local lg=love.graphics



function ChatMessage:init(message)
    -- remove newlines:
    message=message:gsub("\n","")

    self.message = message
    self.creationTime = love.timer.getTime()

    self.opacity = 1
end



function ChatMessage:getLifetime()
    -- returns how long msg has been "alive" for
    return love.timer.getTime() - self.creationTime
end

function ChatMessage:isDone()
    return love.timer.getTime() > (self.creationTime + chat.constants.MESSAGE_DECAY_TIME)
end



local TEST_CHARS = "yb" -- need tall and short-chars for test



function ChatMessage:setOpacity(x)
    self.opacity = x
end


function ChatMessage:onRender(x,y,w,h)
    local font = lg.getFont()

    local textHeight = font:getHeight(TEST_CHARS)
    local scale = h / textHeight

    local BG = chat.constants.CHAT_BACKGROUND_COLOR
    lg.setColor(BG[1],BG[2],BG[3],BG[4]*self.opacity)
    lg.rectangle("fill",x,y,w,h)

    local FG = chat.constants.CHAT_MESSAGE_COLOR
    lg.setColor(FG[1],FG[2],FG[3],FG[4]*self.opacity)
    lg.printf(self.message, x, y, 10000, "left", 0, scale, scale)
end


return ChatMessage
