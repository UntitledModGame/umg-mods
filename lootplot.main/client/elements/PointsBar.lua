

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

    self.pointsVariable = {points = 0, requiredPoints = 0}
    self.pointsText = ui.elements.RichText({
        text = "{outline}Points: {$points}/{$requiredPoints}{/outline}",
        variables = self.pointsVariable,
        scale = 0.25
    })

    self:addChild(self.fancyBar)
    self:addChild(self.imageElement)
    self:addChild(self.pointsText)
end


function PointsBar:onRender(x,y,w,h)
    local context = lp.main.getContext()
    self.pointsVariable.points, self.pointsVariable.requiredPoints = context.points, context.requiredPoints

    local r = ui.Region(x,y,w,h)

    local imgR = self.imageElement:getImageRegion(r)

    self.fancyBar:render(imgR:pad(0.1,0.4,0.1,0.38):get())
    self.imageElement:render(imgR:get())
    self.pointsText:render(imgR:get())
end

return PointsBar
