local fonts = require("client.fonts")

---@class lootplot.main.ActionButton: Element
local ActionButton = ui.Element("lootplot.main:ActionButton")


local DEFAULT_PADDING = 12

local TABLE_ARGS = {"text", "onClick"}

function ActionButton:init(args)
    typecheck.assertKeys(args, TABLE_ARGS)
    self.click = args.onClick
    self.canClick = args.canClick
    self.padding = args.padding or DEFAULT_PADDING

    if type(args.text) == "function" then
        self.textGetter = args.text
    else
        function self.textGetter()
            return tostring(args.text)
        end
    end

    self.textElement = ui.elements.Text({
        color = objects.Color.WHITE,
        font = fonts.getLargeFont()
    })
    self.box = ui.elements.StretchableBox("orange_big", 8, 8, {
        scale = 2,
        stretchType = "repeat",
    })
    self:addChild(self.box)
    self:addChild(self.textElement)
end


function ActionButton:onRender(x,y,w,h)
    self.textElement:setText(self.textGetter())
    self.box:render(x,y,w,h)
    local txtR = ui.Region(x,y,w,h):padRatio(0.1)
    x,y,w,h = txtR:get()
    self.textElement.color = objects.Color.BLACK
    local off = math.floor(h/18)
    self.textElement:render(x-off, y-off, w, h)
    self.textElement.color = objects.Color.WHITE
    self.textElement:render(x, y, w, h)
end



function ActionButton:onClick()
    if (self.canClick and self.canClick()) or (not self.canClick) then
        audio.play("lootplot.sound:click", {volume = 0.35, pitch = 1.1})
        self:click()
    else
        audio.play("lootplot.sound:deny_click", {volume = 0.5})
    end
end




return ActionButton

