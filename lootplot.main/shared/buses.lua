


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
    local ctx = lp.main.getRun()

    if ctx then
        local p = ctx:getPlot()
        local ent = p:getOwnerEntity()
        if not p:isPipelineRunning() then
            lp.resetCombo(ent)
        end
    end
end)


end


