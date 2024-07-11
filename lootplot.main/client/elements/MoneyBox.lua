
local MoneyBox = ui.Element("lootplot.main:MoneyBox")


local boxColor = objects.Color(1,1,1,1)
local textColor = objects.Color(love.math.colorFromBytes(53, 112, 58))


function MoneyBox:init(args)
    self.lastMoney = 0

    self.box = ui.elements.SimpleBox({
        color = boxColor,
        rounding = 4,
        thickness = 0.5
    })
    self:addChild(self.box)

    self.text = ui.elements.Text({
        text = "$0",
        color = textColor,
    })
    self:addChild(self.text)
end


function MoneyBox:onRender(x,y,w,h)
    -- TODO: this is a BIIIT hacky...
    --  OH WELL LOL!
    local ctx = lp.main.getContext()
    local money = ctx.money

    if self.lastMoney ~= money then
        self.text:setText("$" .. money)
        self.lastMoney = money
    end

    self.box:render(x,y,w,h)

    local r = ui.Region(x,y,w,h):pad(0.08)
    self.text:render(r:get())
end


