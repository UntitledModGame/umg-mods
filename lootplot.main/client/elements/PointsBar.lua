local fonts = require("client.fonts")

---@class lootplot.main.PointsBar: Element
local PointsBar = ui.Element("lootplot.main:PointsBar")


function PointsBar:init(args)
    self.fancyBar = ui.elements.FancyBar({
        getProgress = args.getProgress,
        text = "Points",
        mainColor = {
            hue = 0,
            saturation = 1
        },
        catchUpColor = {
            hue = 50,
            saturation = 1
        },
        outlineWidth = 0.01,
    })

    self.pointsText = ui.elements.RichText({
        text = "{outline}Req. Points: 0/0{/outline}",
        scale = 0.375,
        font = fonts.getSmallFont()
    })

    self.box = ui.elements.SimpleBox({
        color = {1,1,1,0},
        rounding = 4,
        thickness = 1
    })
    self:addChild(self.box)

    self:addChild(self.fancyBar)
    self:addChild(self.pointsText)
end


function PointsBar:onRender(x,y,w,h)
    local context = lp.main.getContext()
    self.pointsText:setText(string.format(
        "{outline}Req. Points: %d/%d{/outline}",
        math.min(math.max(context.requiredPoints - context.points, 0), context.requiredPoints), context.requiredPoints
    ))

    local r = ui.Region(x,y,w,h):pad(0.05, 0.02, 0.05, 0.02)

    self.box:render(r:get())
    self.fancyBar:render(r:get())
end

return PointsBar
