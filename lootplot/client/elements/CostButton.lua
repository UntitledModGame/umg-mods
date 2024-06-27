
---@class lootplot.CostButton: Element
local CostButton = ui.Element("lootplot:CostButton")


local DEFAULT_PADDING = 12

local lg=love.graphics

local TABLE_ARGS = {"text", "onClick", "getCost"}

function CostButton:init(args)
    typecheck.assertKeys(args, TABLE_ARGS)
    self.onClick = args.onClick
    self.getCost = args.getCost
    self.prefix = args.text
    self.text = ""
    self.padding = args.padding or DEFAULT_PADDING
end

---@private
function CostButton:_ensureTextElement()
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




function CostButton:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    lg.setColor(self.backgroundColor or objects.Color.WHITE)
    lg.rectangle("fill", r:get())
    lg.setColor(self.outlineColor or objects.Color.BLACK)
    lg.rectangle("line", r:get())

    local cost = self.getCost()
    self.text = self.prefix..": "..cost

    self:_ensureTextElement()
    self.textElement:render(x,y,w,h)
end



function CostButton:onClickPrimary()
    self:onClick()
end




return CostButton

