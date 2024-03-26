

local PlotSlotElement = ui.Element("lootplot:PlotSlotElement")
    :implement(items.SlotElement)


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



local lg=love.graphics

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

    lg.setColor(1,1,1)
    if slotEnt then
        local entX, entY = x+w/2, y+h/2
        rendering.drawEntity(slotEnt, entX,entY, 0, sx,sy)
    end
end



return PlotSlotElement

