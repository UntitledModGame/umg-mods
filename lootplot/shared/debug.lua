


local h = umg.group("item")

umg.on("@tick", function()
    for _, ent in ipairs(h)do
        local ppos = lp.getPos(ent)
        if ppos then
            print(ent.x, ent.y, ppos.slot)
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


