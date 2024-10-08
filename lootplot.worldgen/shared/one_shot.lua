


umg.on("lootplot:entityActivated", function(ent)
    if ent.onActivateOnce then
        ent:onActivateOnce()
        ent.onActivateOnce = false
    end
end)



