local loc = localization.localize

lp.defineItem("lootplot.s0.worldgen:basic_worldgen", {
    name = loc("Worldgen Item"),
    description = loc("It's almost impossible to see this"),

    doomCount = 1,
    ---@param self lootplot.ItemEntity
    onActivateOnce = function(self)
        local selfPPos = assert(lp.getPos(self), "Houston, we have a problem")
        local allocator = lp.worldgen.IslandAllocator(selfPPos:getPlot())
        local sx = (love.math.random() - 0.5) * 4000
        local sy = (love.math.random() - 0.5) * 4000
        allocator:map(function(ppos)
            local x, y = ppos:getCoords()
            return love.math.simplexNoise(sx + x / 50, sy + y / 50) >= 0.2
        end)
        allocator:cullNearbyIslands(3)
        local islands = allocator:generateIslands()

        for _, island in ipairs(islands) do
            if #island >= 3 then
                -- TODO: Spawn locked slot here.
            end
        end
    end
})
