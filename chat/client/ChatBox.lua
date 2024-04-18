

local ChatBox = ui.Element("chat:ChatBox")

local LinkedList = require("_libs.doubly_linked_list")



local lg=love.graphics



function ChatBox:init()
    self.maxMessages = 20

    self.currentMessage = ""
    
    self.isChatOpen = false

    self.heightRatio = 0.5 
    -- should take up this percentage of the screen, vertically

    self.messages = LinkedList.new()
end




local function drawCursor(x,y,w,h)
    local cursorOpacity = (math.sin(item * 12) + 1) / 2
    lg.push("all")
    local opacity = math.floor(cursorOpacity + 0.65)
    lg.setColor(0,0,0,opacity)
    lg.rectangle("fill", x, y, w,h)
    lg.pop()
end



function ChatBox:inputText(txt)
    self.currentMessage = self.currentMessage .. txt
end

function ChatBox:deleteText(numChars)
    numChars = numChars or 1
    local len = #self.currentMessage
    self.currentMessage = self.currentMessage:sub(1, len-numChars)
end


function ChatBox:submitMessage()
    if #self.currentMessage <= 0 then
        return
    end
    chat.message(self.currentMessage)
    self.currentMessage = ""
    self:closeChat()
end


function ChatBox:openChat()
    self.isChatOpen = true
end
function ChatBox:closeChat()
    self.isChatOpen = false
end


function ChatBox:isChatOpen()
    -- checks whether box is open (or not)
end


function ChatBox:pushMessage(str)
    self.messages:pushf(ui.ChatMessage({
        message = str
    }))
    if self.messages:count() >= chat.constants.MESSAGE_HISTORY_SIZE then
        self.messages:popl()
    end
end




local function iterMessage(chatMsg, region)
    if chatMsg:isDone() then
        return false -- no more messages to be drawn.
    else -- draw message at full opacity
        chatMsg:render(region:get())
    end
end



function ChatBox:onRender(x,y,w,h)
    -- x,y,w,h should be the size of the screen
    local r,_ = ui.Region(x,y,w,h):splitVertical(self.heightRatio, 1-self.heightRatio)

    local regions = r:grid(1,self.maxMessages)

    self.messages:foreach(function(chatMsg, i)
        local reg = regions[i]
        if reg then
            chatMsg:render(reg:get())
        end
    end)
end

return ChatBox

