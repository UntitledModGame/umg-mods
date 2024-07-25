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

    self.imageElement = ui.elements.Image({
        image="points_bar"
    })

    self.pointsText = ui.elements.RichText({
        text = "{outline}Req. Points: 0/0{/outline}",
        scale = 0.375,
        font = fonts.getSmallFont()
    })

    self:addChild(self.fancyBar)
    self:addChild(self.imageElement)
    self:addChild(self.pointsText)
end


function PointsBar:onRender(x,y,w,h)
    local context = lp.main.getContext()
    self.pointsText:setText(string.format(
        "{outline}Req. Points: %d/%d{/outline}",
        math.min(math.max(context.requiredPoints - context.points, 0), context.requiredPoints), context.requiredPoints
    ))

    local r = ui.Region(x,y,w,h)

    local imgR = self.imageElement:getImageRegion(r)

    self.fancyBar:render(imgR:pad(0.1,0.4,0.1,0.38):get())
    self.imageElement:render(imgR:get())
    self.pointsText:render(imgR:get())
end

return PointsBar
