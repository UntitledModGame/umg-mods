

local PlotInventory = objects.Class("lootplot:PlotInventory", items.Inventory)



function PlotInventory:init(args)
    typecheck.assertKeys(args, {"plot"})

    self.plot = args.plot
end



function PlotInventory:onItemAdded(itemEnt, slot)
    -- move
end


function PlotInventory:onItemRemoved(itemEnt, slot)

end



return PlotInventory
