

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

    self:addChild(self.fancyBar)
    self:addChild(self.imageElement)
end


function PointsBar:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    
    local imgR = self.imageElement:getImageRegion(r)

    self.fancyBar:render(imgR:pad(0.1,0.35,0.1,0.35):get())
    self.imageElement:render(imgR:get())
end

return PointsBar
