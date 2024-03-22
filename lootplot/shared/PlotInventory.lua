

local PlotInventory = objects.Class("lootplot:PlotInventory", items.Inventory)



function PlotInventory:init(ownerEnt)
    assert(ownerEnt.plot, "plot must be assigned!")
    self.plot = ownerEnt.plot

    self:super({
        size = self.plot.grid.size,
        entity = ownerEnt
    })
end


if server then

function PlotInventory:onItemAdded(itemEnt, slot)
    -- Add to plot
    self.plot:trySetItem(slot, itemEnt)
end


function PlotInventory:onItemRemoved(itemEnt, slot)
    -- Remove from plot
    self.plot:setItem(slot, itemEnt)
end

end


return PlotInventory
