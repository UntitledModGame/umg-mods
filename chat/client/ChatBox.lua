

local ChatBox = ui.Element("chat:ChatBox")

local LinkedList = require("_libs.doubly_linked_list")


local MESSAGE_DECAY_TIME = 5 -- after X seconds, messages will start to fade.
local MESSAGE_FADE_TIME = 0.5 -- how long it takes for msgs to fade.


local lg=love.graphics



function ChatBox:init()
    self.maxMessages = 20
    self.heightRatio = 0.5 
    -- should take up this percentage of the screen, vertically

    self.MAX_CHATHISTORY_SIZE = 300 -- After this many messages, messages begin to be deleted.
    
    self.messages = LinkedList.new()
end



local HEIGHT_TEST_CHARS = "abc"


local function drawCursor(x,y,w,h)
    local cursorOpacity = (math.sin(item * 12) + 1) / 2
    lg.push("all")
    local opacity = math.floor(cursorOpacity + 0.65)
    lg.setColor(0,0,0,opacity)
    lg.rectangle("fill", x, y, w,h)
    lg.pop()
end



local function iterMessage(messageObj, region)
    local dt = item - messageObj.time
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





function ChatBox:pushMessage(str)
    self.messages:pushf(ChatMessage({
        message = str
    }))
    if self.messages:count() >= self.MAX_CHATHISTORY_SIZE then
        self.messages:popl()
    end
end



function ChatBox:onRender(x,y,w,h)
    -- x,y,w,h should be the size of the screen
    local r,_ = ui.Region(x,y,w,h):splitVertical(self.heightRatio, 1-self.heightRatio)

    local regions = r:grid(1,self.maxMessages)

    for i=#regions,1,-1 do
        local obj = regions[i]
    end
end

return ChatBox

