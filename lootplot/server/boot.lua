


local function addBase(worldPlot)
    local grid = worldPlot.plot.grid
    grid:foreachInArea(8,11, 3,6, function(val, x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({
            slot=i, 
            plot=worldPlot.plot
        })

        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end


