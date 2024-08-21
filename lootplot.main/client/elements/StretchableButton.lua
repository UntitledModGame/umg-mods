
---@class lootplot.main.StretchableButton: Element
local StretchableButton = ui.Element("lootplot.main:StretchableButton")

local lg=love.graphics



local function giveTextElement(self, elem)
    if not self.text then
        return
    end

    local textElement = ui.elements.Text({
        text = self.text,
        font = self.font,
        color = self.textColor,
        outline = 2,
        outlineColor = objects.Color.BLACK
    })
    elem:setContent(textElement)
end


function StretchableButton:init(args)
    typecheck.assertKeys(args, {"onClick", "color"})
    self.click = args.onClick
    self.text = args.text
    self.font = args.font or lg.getFont()
    self.outlineColor = args.outlineColor
    self.textColor = args.textColor or objects.Color.WHITE

    self.buttonPressed = ui.elements.StretchableBox("orange_pressed_big", 8, 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.button = ui.elements.StretchableBox(
        "orange_big", {width = 8, height = 8}, {
            scale = 2,
            stretchType = "repeat",
        }
    )

    self:addChild(self.buttonPressed)
    self:addChild(self.button)

    giveTextElement(self, self.button)
    giveTextElement(self, self.buttonPressed)
end


function StretchableButton:onRender(x,y,w,h)
    if self:isHovered() then
        lg.setColor(0.5,0.5,0.5)
    else
        lg.setColor(objects.Color.WHITE)
    end

    if self:isPressedBy("input:CLICK_PRIMARY") then
        self.buttonPressed:render(x,y,w,h)
    else
        self.button:render(x,y,w,h)
    end
end


function StretchableButton:onControlRelease(cont)
    if cont == "input:CLICK_PRIMARY" then
        self:click()
    end
end

return StretchableButton
