return lp.defineSlot("lootplot:rerollButtonSlot", {
    image = "reroll_button_up",
    activateAnimation = {
        activate = "reroll_button_hold",
        idle = "reroll_button_up",
        duration = 0.4
    },
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            ppos:getPlot():trigger("REROLL")
        end
    end,
})