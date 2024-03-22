

local PlotSlotElement = ui.Element("lootplot:PlotSlotElement")

local lg=love.graphics

local ARGS = {"x", "y", "plot"}

function PlotSlotElement:init(args)
    typecheck.assertKeys(args, ARGS)
    self.x = args.x
    self.y = args.y
    self.plot = args.plot
end



function PlotSlotElement:onRender(x,y,w,h)
    --[[
        Should render the slot entity, 
        via the rendering mod.

        Make sure to pass in correct scale!!!
            Will need to fudge with the entity size a bit i reckon.
    ]]
    lg.setColor(0,0,0,0)
    lg.rectangle("line", x,y,w,h)
end



return PlotSlotElement

