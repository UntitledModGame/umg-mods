



local function addShop(worldPlot)
    -- TODO: Add shop-slots here
end


local function addBase(worldPlot)
    local grid = worldPlot.plot.grid
    for x=8,11 do
        for y=3,6 do
            local i = grid:coordsToIndex(x,y)
            local ppos = lp.PPos({
                slot=i, 
                plot=worldPlot.plot
            })

            local basicSlot = server.entities.slot()
            lp.setSlot(ppos, basicSlot)
        end
    end
end



umg.on("@createWorld", function()
    -- create world plot
    local worldPlot = server.entities.world()

    addShop(worldPlot)
    addBase(worldPlot)
end)



umg.on("@playerJoin", function(clientId)
    server.entities.player(clientId)
end)


