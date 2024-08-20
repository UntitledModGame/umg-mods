local imageConst = require("client.image_const")

---@class lootplot.main.StretchableButton: Element
local StretchableButton = ui.Element("lootplot.main:StretchableButton")

local lg=love.graphics

local BUTTON_PATH = "assets/images/buttons/%s_big.png"
local BUTTON_PRESSED_PATH = "assets/images/buttons/%s_pressed_big.png"

function StretchableButton:init(args)
    typecheck.assertKeys(args, {"onClick", "color"})
    self.click = args.onClick
    self.text = args.text
    self.font = args.font or lg.getFont()
    self.outlineColor = args.outlineColor
    self.textColor = args.textColor or objects.Color.WHITE

    self.n9pButton = n9slice.loadFromImageQuad(
        lg.newImage(string.format(BUTTON_PATH, args.color)),
        nil,
        {template = imageConst.NINEPATCH_TEMPLATE, stretchType = "repeat"}
    )
    self.n9pButtonPressed = n9slice.loadFromImageQuad(
        lg.newImage(string.format(BUTTON_PRESSED_PATH, args.color)),
        nil,
        {template = imageConst.NINEPATCH_PRESSED_TEMPLATE, stretchType = "repeat"}
    )
    self.button = ui.elements.StretchableBox(self.n9pButton, {scale = args.scale or 1})

    self:addChild(self.button)
end

local function ensureTextElement(self)
    if not self.textElement then
        self.textElement = ui.elements.Text({
            text = self.text,
            font = self.font,
            color = self.textColor,
            outline = 2,
            outlineColor = objects.Color.BLACK
        })
        self.button:setContent(self.textElement)
    end

    if self.textElement:getText() ~= self.text then
        -- we need to update!
        self.textElement:setText(self.text)
    end
end

function StretchableButton:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    ensureTextElement(self)
    if self:isHovered() then
        lg.setColor(0.5,0.5,0.5)
    else
        lg.setColor(objects.Color.WHITE)
    end
    self.button:render(x, y, w, h)
end

function StretchableButton:onClick(cont)
    -- Cannot use self:isClicked() because it's set AFTER this callback.
    if cont == "input:CLICK_PRIMARY" then
        self.button:setN9P(self.n9pButtonPressed)
    end
end

function StretchableButton:onControlRelease(cont)
    if cont == "input:CLICK_PRIMARY" then
        self.button:setN9P(self.n9pButton)
        self:click()
    end
end

return StretchableButton
