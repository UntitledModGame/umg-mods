

local PlotSlotElement = ui.Element("lootplot:PlotSlotElement")


local ARGS = {"x", "y", "plot"}

function PlotSlotElement:init(args)
    objects.assertKeys(args, ARGS)
    self.x = args.x
    self.y = args.y
    self.plot = args.plot
end



function PlotSlotElement:onRender(x,y,w,h)
    --[[
        render the slot entity
    ]]
end



return PlotSlotElement

