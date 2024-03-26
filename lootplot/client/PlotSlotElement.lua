

local PlotSlotElement = ui.Element("lootplot:PlotSlotElement")
    :implement(items.SlotElement)

local lg=love.graphics

local ARGS = {"ppos", "entity"}

function PlotSlotElement:init(args)
    typecheck.assertKeys(args, ARGS)
    self.ppos = args.ppos
    self.entity = args.entity

    self:super({
        slot = args.ppos.slot,
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
    local SIZE = 24
    local sx, sy = w/SIZE, h/SIZE
    local slotEnt = posToSlot(self.ppos)
    if slotEnt then
        rendering.drawEntity(slotEnt, x,y, 0, sx,sy)
    end
end



return PlotSlotElement

