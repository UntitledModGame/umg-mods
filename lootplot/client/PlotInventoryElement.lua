
local PlotSlotElement = require("client.PlotSlotElement")


local PlotInventoryElement = ui.Element("lootplot:PlotInventoryElement")


function PlotInventoryElement:init(plot)
    self.plot = plot
    self.grid = plot.grid
    self:bindEntity(plot.ownerEnt)

    self.slotElements = objects.Array()

    self.grid:foreach(function(_val, x,y)
        local slotElem = PlotSlotElement({
            x = x, y = y, plot = plot
        })
        self:addChild(slotElem)
        self.slotElements:add(slotElem)
    end)
end


local OUTER_PADDING = 0.05
local SLOT_PADDING = 0.05

function PlotInventoryElement:onRender(x,y,w,h)
    local bounds = ui.Region(x,y,w,h)
        :pad(0.05)
    
    local grid = self.grid
    local region = ui.Region(0,0, grid.width, grid.height)
        :scaleToFit(bounds)

    local slotSize = region.width / grid.width
    for xx=0, grid.width-1 do
        for yy=0, grid.height-1 do
            local r = ui.Region(
                xx * slotSize,
                yy * slotSize,
                slotSize, slotSize
            ):pad(SLOT_PADDING)
            
            local i = self.grid:coordsToIndex(xx,yy)

            local slotElem = self.slotElements[i]
            
            slotElem:render(r:get())
            error([[
                todo: completely untested!!
            ]])
        end
    end
end



return PlotInventoryElement
