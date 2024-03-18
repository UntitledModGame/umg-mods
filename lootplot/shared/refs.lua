
--[[

Back-referencing:

ent.plot component, ent.slot component

NOTE:
`plot` and `slot` are READ-ONLY components!!!!
They are NOT to be modified!!!!


]]


local plotEnts = umg.group("plot")




local event 
if server then
    event = "@tick"
else
    event = "@update"
end

umg.on(event, function(dt)
    for _, plotEnt in ipairs(plotEnts) do
        local plot = plotEnt.plot
        plot:foreach(function(slotEnt, slot)
            slotEnt._plot = plot
            slotEnt._slot = slot
        end)
    end
end)


