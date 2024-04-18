

local ChatMessage = ui.Element("chat:ChatMessage")

local lg=love.graphics



function ChatMessage:init(message)
    -- remove newlines:
    message=message:gsub("\n","")

    self.message = message
    self.creationTime = love.timer.getTime()
end


function ChatMessage:isDone()
    return love.timer.getTime() > (self.creationTime + chat.constants.MESSAGE_DECAY_TIME)
end

local function getLifetime(self)
    -- returns how long msg has been "alive" for
    return love.timer.getTime() - self.creationTime
end



local TEST_CHARS = "yb" -- need tall and short-chars for test

function ChatMessage:onRender(x,y,w,h)
    local MESSAGE_DECAY_TIME = chat.constants.MESSAGE_DECAY_TIME
    local MESSAGE_FADE_TIME = chat.constants.MESSAGE_FADE_TIME

    lg.rectangle("fill",x,y,w,h)
    local font = lg.getFont()

    local textHeight = font:getHeight(TEST_CHARS)

    local scale = h / textHeight

    local opacity = 1 - (getLifetime(self)-MESSAGE_DECAY_TIME)/MESSAGE_FADE_TIME

    lg.setColor(chat.constants.CHAT_BACKGROUND_COLOR)
    lg.rectangle("fill",x,y,w,h)
    lg.setColor(chat.constants.CHAT_MESSAGE_COLOR)
    lg.printf(self.message, x, y, nil, nil, 0, scale, scale)
end


return ChatMessage
