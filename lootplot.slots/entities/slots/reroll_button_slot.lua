return lp.defineSlot("lootplot:rerollButtonSlot", {
    image = "reroll_button_up",
    triggers={},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            ppos:getPlot():trigger("REROLL")
        end
    end,
})
