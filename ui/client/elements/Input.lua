local Element = require("client.newElement")
local Text = require("client.elements.Text")

---@class ui.Input: Element
local Input = Element("ui:Input")

local DEFAULT_MAX_LENGTH = 50



function Input:init(args)
    args = args or {}
    self.text = Text({
        color = args.textColor or objects.Color.BLACK,
        text = args.startValue or ""
    })
    self:addChild(self.text)
    self.onSubmit = args.onSubmit
    self.maxLength = args.maxLength or DEFAULT_MAX_LENGTH
    self.background = args.backgroundColor or objects.Color.WHITE
end

if false then
    ---@param args {textColor:objects.Color?,startValue:string?,maxLength:integer?,backgroundColor:objects.Color?}?
    ---@return ui.Input
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function Input(args) end
end

local lg=love.graphics

function Input:onRender(x,y,w,h)
    local region = layout.Region(x,y,w,h)
    love.graphics.setColor(self.background)
    lg.rectangle("fill",x,y,w,h)

    local textRegion = region:padUnit(10)
    if self:isFocused() then
        local _, cursorRegion = textRegion:splitHorizontal(0.9, 0.1)
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("fill",cursorRegion:get())
        end
    end
    self.text:render(textRegion:get())
end


function Input:onClick()
    self:focus()
end



local SUBMIT = "return"
local BACKSPACE = "backspace"

function Input:onKeyPress(_, scancode, isrepeat)
    if not self:isFocused() then
        return
    end
    if scancode == SUBMIT then
        self:unfocus()
        return true
    end

    if scancode == BACKSPACE then
        -- delete character
        local txt = self.text:getText()
        self.text:setText(txt:sub(1, -2))
        return true
    end
end


function Input:onTextInput(text)
    if not self:isFocused() then
        return
    end
    local txt = self.text:getText() .. text
    self.text:setText(txt)
end


function Input:onUnfocus()
    if self.onSubmit then
        self:onSubmit(self.text:getText())
    end
end


function Input:getText()
    return self.text:getText()
end

return Input

