
local PlotSlotElement = require("client.PlotSlotElement")


local PlotInventoryElement = ui.Element("lootplot:PlotInventoryElement")


local ARGS={"entity"}

function PlotInventoryElement:init(args)
    typecheck.assertKeys(args,ARGS)
    local plot = args.ownerEnt.plot
    assert(plot, "needs plot!")
    self.plot = plot
    self.grid = plot.grid
    self:bindEntity(args.ownerEnt)

    self.color=args.color or objects.Color.WHITE

    self.slotElements = objects.Array()

    self.grid:foreach(function(_val, x,y)
        local slot = self.grid:coordsToIndex(x,y)
        local slotElem = PlotSlotElement({
            slot = slot, 
            plot = plot
        })
        self:addChild(slotElem)
        self.slotElements:add(slotElem)
    end)
end



local lg=love.graphics

local OUTER_PADDING = 0.05
local SLOT_PADDING = 0.05

function PlotInventoryElement:onRender(x,y,w,h)
    lg.push("all")
    lg.setColor(self.color)
    lg.rectangle("fill",x,y,w,h)
    lg.setColor(0,0,0)
    lg.setLineWidth(2)
    lg.rectangle("line",x,y,w,h)

    local bounds = ui.Region(x,y,w,h)
        :pad(OUTER_PADDING)
    
    local grid = self.grid
    local region = ui.Region(0,0, grid.width, grid.height)
        :scaleToFit(bounds)
        :center(bounds)

    local slotSize = region.w / grid.width
    grid:foreach(function(_val, xx,yy)
        local i = self.grid:coordsToIndex(xx,yy)
        local slotElem = self.slotElements[i]

        local X = region.x + xx*slotSize
        local Y = region.y + yy*slotSize
        local r = ui.Region(X, Y, slotSize, slotSize)
            :pad(SLOT_PADDING)

        slotElem:render(r:get())
    end)
    lg.pop()
end



return PlotInventoryElement
