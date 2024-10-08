local Element = require("client.newElement")
local Text = require("client.elements.Text")

---@class ui.Input: Element
local Input = Element("ui:Input")

local DEFAULT_MAX_LENGTH = 50

local SUBMIT = "ui:SUBMIT_TEXT"
local BACKSPACE = "ui:DELETE_TEXT"
input.defineControls({BACKSPACE, SUBMIT})
input.setControls({
    [BACKSPACE] = {"key:backspace"},
    [SUBMIT] = {"key:return"},
})


---@param args {textColor:objects.Color?,align:love.AlignMode?,font:love.Font?,startValue:string?,maxLength:integer?,backgroundColor:objects.Color?,getScale?:(fun():number),onSubmit?:fun(self:ui.Input,text:string)}?
function Input:init(args)
    args = args or {}
    self.color = args.textColor or objects.Color.BLACK
    self.text = Text({
        color = self.color,
        text = args.startValue or "",
        font = args.font,
        align = args.align,
        getScale = args.getScale,
    })
    self:addChild(self.text)
    self.onSubmit = args.onSubmit
    self.maxLength = args.maxLength or DEFAULT_MAX_LENGTH
    self.background = args.backgroundColor or objects.Color.WHITE
    self.getScale = args.getScale
end

if false then
    ---@param args {textColor:objects.Color?,align:love.AlignMode?,font:love.Font?,startValue:string?,maxLength:integer?,backgroundColor:objects.Color?,getScale?:(fun():number),onSubmit?:fun(self:ui.Input,text:string)}?
    ---@return ui.Input
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function Input(args) end
end

local lg=love.graphics

function Input:onRender(x,y,w,h)
    local region = layout.Region(x,y,w,h)
    love.graphics.setColor(self.background)
    lg.rectangle("fill",x,y,w,h)

    if self:isFocused() then
        local _, cursorRegion = region:splitHorizontal(0.9, 0.1)
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill",cursorRegion:get())
        end
    end
    self.text:render(region:get())
end


function Input:onClick()
    self:focus()
end



function Input:onControlPress(controlEnum, isrepeat)
    if not self:isFocused() then
        return
    end
    if controlEnum == "input:ESCAPE" or controlEnum == SUBMIT then
        self:unfocus()
        return true
    end

    if controlEnum == BACKSPACE then
        -- delete character
        -- TODO: Make it UTF-8 friendly
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

