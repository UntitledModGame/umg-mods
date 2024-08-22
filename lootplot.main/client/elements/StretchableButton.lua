local StretchableBox = require("client.elements.StretchableBox")

---@class lootplot.main.StretchableButton: Element
local StretchableButton = ui.Element("lootplot.main:StretchableButton")

local lg=love.graphics


---@param self lootplot.main.StretchableButton
---@param elem lootplot.main.StretchableBox
local function giveTextElement(self, elem)
    if not self.text then
        return
    end

    local textElement = ui.elements.Text({
        text = tostring(self.text),
        font = self.font,
        color = self.textColor,
        outline = 1.5,
        outlineColor = self.outlineColor or objects.Color.BLACK
    })
    elem:setContent(textElement)
end

---@param args {onClick:function,color:string,text?:string|fun():(string),font:love.Font?,outlineColor:objects.Color?,textColor:objects.Color?}
function StretchableButton:init(args)
    typecheck.assertKeys(args, {"onClick", "color"})
    self.click = args.onClick
    self.text = args.text
    self.font = args.font or lg.getFont()
    self.outlineColor = args.outlineColor
    self.textColor = args.textColor or objects.Color.WHITE

    self.buttonPressed = StretchableBox(args.color.."_pressed_big", 8, 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.button = StretchableBox(args.color.."_big", 8, 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self:addChild(self.buttonPressed)
    self:addChild(self.button)

    giveTextElement(self, self.button)
    giveTextElement(self, self.buttonPressed)
end

if false then
    ---@param args {onClick:function,color:string,text?:string|fun():(string),font:love.Font?,outlineColor:objects.Color?,textColor:objects.Color?}
    ---@return lootplot.main.StretchableButton
    function StretchableButton(args) end
end

function StretchableButton:onRender(x,y,w,h)
    if self:isHovered() then
        lg.setColor(0.5,0.5,0.5)
    else
        lg.setColor(objects.Color.WHITE)
    end

    local usedButton = self:isPressedBy("input:CLICK_PRIMARY") and self.buttonPressed or self.button
    if type(self.text) == "function" then
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
