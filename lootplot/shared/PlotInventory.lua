

local PlotInventory = objects.Class("lootplot:PlotInventory", items.Inventory)



function PlotInventory:init(args)
    typecheck.assertKeys(args, {"plot"})

    self.plot = args.plot
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
