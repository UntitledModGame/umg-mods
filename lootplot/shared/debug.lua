


local h = umg.group("item")

umg.on("@tick", function()
    for _, ent in ipairs(h)do
        local ppos = lp.getPos(ent)
        if ppos then
            print("DBG::", ent.x, ent.y, ppos.slot)
        end
    end
end)


umg.on("@debugComponentChange", function (ent, comp, val)
    if client and ent.item and comp == "x" then
        if val-math.floor(val)>0.3 then
            --umg.melt("1.")
        end
    end
end)

--[[

It appears like the client positioning is lagging behind for some reason.

I'm guessing this is due to automatic syncing,
but I'm not sure

perhaps we should turn off auto sync components and see if it works?

Ok it looks like the component is jittering back and forth between the old position.
not sure what could be causing this though;

]]


