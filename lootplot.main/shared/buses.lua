


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
    if lp.main.isReady() then
        local ctx = lp.main.getRun()

        local p = ctx:getPlot()
        local ent = p:getOwnerEntity()
        if not p:isPipelineRunning() then
            lp.resetCombo(ent)
        end
    end
end)


end


