

local PlotInventory = objects.Class("lootplot:PlotInventory")
    :implement(items.Inventory)



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

function PlotInventory:isItemAdditionBlocked(itemEnt, slot)
    if not self.plot:getSlot(slot) then
        -- if there's no slot to be added: block!
        return true
    end
end

end


return PlotInventory
