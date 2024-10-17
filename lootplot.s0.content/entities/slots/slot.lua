local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:slot", {
    init = function(ent)
        if math.random()<0.5 then
            lp.modifierBuff(ent, "pointsGenerated", 5)
        else
            lp.modifierBuff(ent, "pointsGenerated", -5)
        end
    end,
    image = "slot",
    name = loc("Basic Slot")
})

