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

    if type(args.text) == "function" then
        self.textGetter = args.text
    else
        function self.textGetter()
            return tostring(args.text)
        end
    end

    self.textElement = ui.elements.Text({
        color = objects.Color.BLACK,
        font = fonts.getLargeFont()
    })
    self.simpleBox = ui.elements.SimpleBox({
        color = args.color or objects.Color.WHITE,
        rounding = 11
    })
    self:addChild(self.simpleBox)
    self:addChild(self.textElement)
end


function ActionButton:onRender(x,y,w,h)
    self.textElement:setText(self.textGetter())
    self.simpleBox:render(x,y,w,h)
    self.textElement:render(x, y, w, h)
end



function ActionButton:onClickPrimary()
    if (self.canClick and self.canClick()) or (not self.canClick) then
        self:onClick()
    end
end




return ActionButton

