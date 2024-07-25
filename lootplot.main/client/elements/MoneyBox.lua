local fonts = require("client.fonts")
local BulgeText = require("client.BulgeText")

---@class lootplot.main.MoneyBox: Element
local MoneyBox = ui.Element("lootplot.main:MoneyBox")

local boxColor = objects.Color(1,1,1,1)
local textColor = objects.Color(love.math.colorFromBytes(53, 112, 58))
local textColorSubtract = objects.Color(love.math.colorFromBytes(168, 30, 15))


function MoneyBox:init(args)
    self.lastMoney = 0

    self.box = ui.elements.SimpleBox({
        color = boxColor,
        rounding = 4,
        thickness = 0.5
    })
    self:addChild(self.box)

    self.money = 0 -- to track old money value
    self.shakeDuration = 0

    function self.getMoney()
        local money = lp.main.getContext().money
        if money > self.money then
            self.shakeDuration = 0
        elseif money < self.money then
            -- Shake it
            self.shakeDuration = love.timer.getTime() + 0.7
        end
        return money
    end

    self.text = ui.elements.RichText({
        font = fonts.getLargeFont()
    })
    self:addChild(self.text)
end

---@param region Region
local function getRegionWithOffset(region, ox, oy)
    local x, y, w, h = region:get()
    return x + ox, y + oy, w, h
end

function MoneyBox:onRender(x,y,w,h)
    -- TODO: this is a BIIIT hacky...
    --  OH WELL LOL!
    -- local ctx = lp.main.getContext()
    -- local money = ctx.money

    -- if self.lastMoney ~= money then
    --     self.text:setText("$" .. money)
    --     self.lastMoney = money
    -- end

    self.box:render(x,y,w,h)
    self.text:setText("$"..self.getMoney())

    local r = ui.Region(x,y,w,h):pad(0.08)
    local ox, oy = 0, 0
    if self.shakeDuration > love.timer.getTime() then
        ox = (love.math.random() * 2 - 1) * 3
        oy = (love.math.random() * 2 - 1) * 3
        love.graphics.setColor(textColorSubtract)
    else
        love.graphics.setColor(textColor)
    end
    self.text:render(getRegionWithOffset(r, ox, oy))
end


