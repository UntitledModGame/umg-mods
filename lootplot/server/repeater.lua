

umg.on("lootplot:entityActivated", function(ent)
    local ppos = lp.getPos(ent)
    if ppos and ent.repeatActivations then
        lp.queueWithEntity(ent, function (e)
            lp.tryActivateEntity(e)
        end)
        lp.wait(ppos, 0.33)
    end
end)

