
---@class lootplot.SellButton: Element
local SellButton = ui.Element("lootplot:SellButton")


local DEFAULT_PADDING = 12

local lg=love.graphics


function SellButton:init(args)
    typecheck.assertKeys(args, {"onSell", "getPrice"})
    self.onClick = args.onSell
    self.getPrice = args.getPrice
    self.text = "Sell"
    self.padding = args.padding or DEFAULT_PADDING
end

---@private
function SellButton:_ensureTextElement()
    if not self.textElement then
        self.textElement = ui.elements.Text({
            text = self.text
        })
        self:addChild(self.textElement)
    end

    if self.textElement.text ~= self.text then
        -- we need to update!
        self.textElement.text = self.text
    end
end




function SellButton:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    lg.setColor(self.backgroundColor or objects.Color.WHITE)
    lg.rectangle("fill", r:get())
    lg.setColor(self.outlineColor or objects.Color.BLACK)
    lg.rectangle("line", r:get())

    local price = self.getPrice()
    self.text = "Sell: "..price

    self:_ensureTextElement()
    self.textElement:render(x,y,w,h)
end



function SellButton:onClickPrimary()
    self:onClick(self.entity)
end




return SellButton

