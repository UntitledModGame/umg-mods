


--[[
TODO:

should these be here???
]]

if server then

umg.on("lootplot:entityActivated", function(ent)
    lp.incrementCombo(ent)
end)

umg.on("lootplot.targets:targetActivated", function(ent)
    lp.incrementCombo(ent)
end)

umg.on("@tick", function(dt)
    local ctx = lp.singleplayer.getRun()

    if ctx then
        local p = ctx:getPlot()
        local ent = p:getOwnerEntity()
        if not p:isPipelineRunning() then
            lp.resetCombo(ent)
        end
    end
end)




--------------------------------
-- Speed up the pipeline when there are a lot of slots.
--------------------------------
umg.answer("lootplot:getPipelineDelayMultiplier", function(plot)
    ---@cast plot lootplot.Plot
    local numVisibleSlots = 0
    plot:foreachSlot(function(ent, ppos)
        --[[
        NOTE: this is VERY inefficient operation;
        since we iterate over the whole plot!

        its fine tho, because `getPipelineDelayMultiplier`
        is only called once per tick, (at most)

        If this REALLY needs to be optimized, 
        we should keep a running track of slots
        ]]
        if plot:isFogRevealed(ppos, lp.singleplayer.PLAYER_TEAM) then
            numVisibleSlots = numVisibleSlots + 1
        end
    end)

    -- NOOMA (Numbers-Out-Of-My-Ass)
    local speedMult = (numVisibleSlots-12) / 30
    return 1 / math.max(1, speedMult)
end)



end


