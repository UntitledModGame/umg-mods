local StretchableBox = require("client.elements.StretchableBox")
local globalScale = require("client.globalScale")
local fonts = require("client.fonts")

---@class lootplot.main.StretchableButton: Element
local StretchableButton = ui.Element("lootplot.main:StretchableButton")

local lg=love.graphics

local BUTTON_PADDING = {4, 5, 5, 7}

---@param self lootplot.main.StretchableButton
---@param elem lootplot.main.StretchableBox
local function giveTextElement(self, elem)
    if not self.text then
        return
    end

    local textElement = ui.elements.Text({
        text = tostring(self.text),
        font = fonts.getLargeFont(),
        color = objects.Color.WHITE,
        outline = 1,
        outlineColor = objects.Color.BLACK,
        getScale = function()
            return globalScale.get() * self.scale
        end,
        rescale = true
    })
    elem:setContent(textElement)
end

function StretchableButton:init(args)
    typecheck.assertKeys(args, {"onClick", "color"})
    self.click = args.onClick
    self.text = args.text
    self.color = args.color
    self.scale = args.scale or 1

    self.buttonPressed = StretchableBox("white_pressed_big", BUTTON_PADDING, {
        scale = self.scale,
        stretchType = "repeat",
    })

    self.button = StretchableBox("white_big", BUTTON_PADDING, {
        scale = self.scale,
        stretchType = "repeat",
    })

    self:addChild(self.buttonPressed)
    self:addChild(self.button)

    giveTextElement(self, self.button)
    giveTextElement(self, self.buttonPressed)
end

if false then
    ---@param args {onClick:function,color:objects.Color,text?:string|fun():(string),scale:number?}
    ---@return lootplot.main.StretchableButton
    function StretchableButton(args) end
end

function StretchableButton:onRender(x,y,w,h)
    local c = self.color
    if self:isHovered() then
        local r,g,b,a = c[1],c[2],c[3],c[4]
        lg.setColor(r*0.5,g*0.5,b*0.5,a)
    else
        lg.setColor(c)
    end

    local usedButton = self:isPressedBy("input:CLICK_PRIMARY") and self.buttonPressed or self.button
    if objects.isCallable(self.text) then
        usedButton:getContent():setText(self.text())
    end

    usedButton:render(x, y, w, h)
end


function StretchableButton:onControlRelease(cont)
    if cont == "input:CLICK_PRIMARY" then
        self:click()
    end
end

return StretchableButton
