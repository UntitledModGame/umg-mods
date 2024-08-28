local loc = localization.newLocalizer()

return lp.defineSlot("lootplot.content.s0:glass_slot", {
    image = "glass_slot",
    name = loc("Glass slot"),
    description = loc("Has a 20% chance of being destroyed when activated"),
    onActivate = function(ent)
        if math.random() < 0.2 then
            -- WELP! riparoni pepperoni
            lp.destroy(ent)
        end
    end
})

