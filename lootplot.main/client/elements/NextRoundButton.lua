local fonts = require("client.fonts")

---@class lootplot.main.NextRoundbutton: Element
local NextRoundbutton = ui.Element("lootplot.main:NextRoundbutton")



local color = objects.Color(love.math.colorFromBytes(241, 196, 15, 255))

local hovColor = color:clone()
do
local h,s,l = color:getHSL()
hovColor:setHSL(h,s-0.35,l)
end



function NextRoundbutton:init(args)
    self.box = ui.elements.SimpleBox({
        color = color,
        rounding = 4,
        thickness = 1
    })
    self:addChild(self.box)

    self.readyText = ui.elements.RichText({
        -- text = "{wavy amp=2}Ready{/wavy}",
        text = "Ready",
        color = objects.Color.BLACK,
        font = fonts.getLargeFont()
    })
    self.roundText = ui.elements.Text({
        text = "Round 0/0",
        font = fonts.getSmallFont()
    })
    self:addChild(self.readyText)
    self:addChild(self.roundText)
end



function NextRoundbutton:onClickPrimary()
    local ctx = lp.main.getContext()
    if ctx:canGoNextRound() then
        ctx:goNextRound()
    end
end


function NextRoundbutton:onRender(x,y,w,h)
    if self:isHovered() then
        self.box:setColor(hovColor)
    else
        self.box:setColor(color)
    end
    self.box:render(x,y,w,h)

    local context = lp.main.getContext()
    self.roundText:setText(string.format("Round %d/%d", context.round, context.maxRound))

    local topTextRegion, bottomTextRegion = ui.Region(x,y,w,h):pad(0.08):splitVertical(3, 2)
    self.readyText:render(topTextRegion:get())
    self.roundText:render(bottomTextRegion:get())
end

