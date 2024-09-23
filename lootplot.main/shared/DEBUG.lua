
if server then

umg.on("lootplot:entityActivated", function(ent)
    if ent.item then
        print("ACT:", ent)
    end
end)

umg.on("lootplot.targets:targetActivated", function(ent, ppos, targEnt)
    print("TARGETTT:", ent, targEnt)
end)


end
