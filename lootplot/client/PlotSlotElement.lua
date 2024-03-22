

local PlotSlotElement = ui.Element("lootplot:PlotSlotElement")
    :implement(items.SlotElement)

local lg=love.graphics

local ARGS = {"slot", "entity"}

function PlotSlotElement:init(args)
    typecheck.assertKeys(args, ARGS)
    self.slot = args.slot
    self.entity = args.entity

    self:super({
        slot = args.slot,
        inventory = self.entity.inventory
    })
end



function PlotSlotElement:onRender(x,y,w,h)
    --[[
        Should render the slot entity, 
        via the rendering mod.

        Make sure to pass in correct scale!!!
            Will need to fudge with the entity size a bit i reckon.
    ]]
    lg.setColor(0,0,0)
    lg.rectangle("fill", x,y,w,h)
end



return PlotSlotElement

