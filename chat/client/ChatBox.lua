

local ChatBox = ui.Element("chat:ChatBox")

local LinkedList = require("_libs.doubly_linked_list")



local lg=love.graphics



function ChatBox:init()
    self.maxMessages = 20
    self.currentMessage = ""
    self._isChatOpen = false
    self.heightRatio = 0.5 -- takes up 50% of screen height
    self.messages = LinkedList.new()

    self:makeRoot()
    self:setPassthrough(true)
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


local function popChar(self)
    -- pops 1 utf8 character off the string

    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(self.currentMessage, -1)
    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        self.currentMessage = string.sub(self.currentMessage, 1, byteoffset - 1)
    end
end

function ChatBox:deleteText(numChars)
    numChars = numChars or 1
    for _=1,numChars do
        popChar(self)
    end
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
    self._isChatOpen = true
end
function ChatBox:closeChat()
    self._isChatOpen = false
    self.currentMessage = ""
end


function ChatBox:isChatOpen()
    -- checks whether chat is open
    -- (ie. whether we are typing)
    return self._isChatOpen
end


function ChatBox:pushMessage(str)
    local elem = ui.elements.ChatMessage(str)
    self.messages:pushf(elem)
    self:addChild(elem)

    if self.messages:count() >= chat.constants.MESSAGE_HISTORY_SIZE then
        local chatMsg = self.messages:popl()
        self:removeChild(chatMsg)
    end
end



local TEST_CHARS = "yb" -- need tall and short-chars for test

function ChatBox:renderCurrentMessage(x,y,_w,h)
    -- renders the message that is being typed
    local font = lg.getFont()

    local textHeight = font:getHeight(TEST_CHARS)
    local scale = h / textHeight

    -- Add blinking cursor:
    local t = love.timer.getTime()
    local msg = self.currentMessage .. (math.floor(t*2)%2==0 and "|" or "")

    lg.setColor(chat.constants.CHAT_MESSAGE_COLOR)
    lg.printf(msg, x, y, 10000, "left", 0, scale, scale)
end



function ChatBox:onRender(x,y,w,h)
    -- x,y,w,h should be the size of the screen
    local _,r = ui.Region(x,y,w,h):splitVertical(1-self.heightRatio, self.heightRatio)

    local regions = objects.Array(r:grid(1,self.maxMessages))
    regions:reverse()

    local DECAY_TIME = chat.constants.MESSAGE_DECAY_TIME
    local FADE_TIME = chat.constants.MESSAGE_FADE_TIME

    if self:isChatOpen() then
        self:renderCurrentMessage(regions[1]:get())
    end

    self.messages:foreachWithBreak(function(chatMsg, i)
        -- this is inefficient, because it loops the entire linkedlist,
        -- even if no messages are visible. Oh well!
        local reg = regions[i+1]

        local opacity = 1 - (chatMsg:getLifetime()-DECAY_TIME)/FADE_TIME
        if self:isChatOpen() then
            -- if chat is open, messages are always visible
            opacity = 1
        end

        if reg then
            chatMsg:setOpacity(opacity)
            chatMsg:render(reg:get())
        else
            return true -- BREAK!
        end
    end)
end

return ChatBox

