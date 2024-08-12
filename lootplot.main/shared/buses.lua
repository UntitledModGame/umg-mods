


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



umg.on("lootplot:entityReset", function(ent)
    --[[
    TODO: does this even make sense??
    ]]
    lp.resetCombo(ent)
end)

end


