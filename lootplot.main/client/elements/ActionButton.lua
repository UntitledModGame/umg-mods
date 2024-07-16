local fonts = require("client.fonts")

---@class lootplot.main.ActionButton: Element
local ActionButton = ui.Element("lootplot.main:ActionButton")


local DEFAULT_PADDING = 12

local lg=love.graphics

local TABLE_ARGS = {"text", "onClick"}

function ActionButton:init(args)
    typecheck.assertKeys(args, TABLE_ARGS)
    self.onClick = args.onClick
    self.canClick = args.canClick
    self.padding = args.padding or DEFAULT_PADDING

    local constructor = text.Text:isInstance(args.text) and ui.elements.RichText or ui.elements.Text
    self.textElement = constructor({
        text = args.text,
        color = objects.Color.BLACK,
        font = fonts.getLargeFont()
    })
    self:addChild(self.textElement)
end


function ActionButton:onRender(x,y,w,h)
    lg.setColor(self.backgroundColor or objects.Color.WHITE)
    lg.rectangle("fill", x, y, w, h)
    lg.setColor(self.outlineColor or objects.Color.BLACK)
    lg.rectangle("line", x, y, w, h)
    self.textElement:render(x, y, w, h)
end



function ActionButton:onClickPrimary()
    if (self.canClick and self.canClick()) or (not self.canClick) then
        self:onClick()
    end
end




return ActionButton

