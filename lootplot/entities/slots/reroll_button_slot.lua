return lp.defineSlot("lootplot:rerollButtonSlot", {
    image = "slot",
    color = {1, 0.6, 0.9},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            ppos.plot:trigger("REROLL")
        end
    end,
})
