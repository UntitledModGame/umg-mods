

return lp.defineSlot("lootplot.content.s0:dirt_slot", {
    image = "dirt_slot1",
    name = localization.localize("Dirt slot"),
    description = localization.localize("Can hold {c r=0 g=1 b=0}{wavy}plant{/wavy}{/c} items"),
    baseTraits = {"lootplot.content.s0:BOTANIC"},

    init = function(ent)
        -- randomly flip the image to make it look cool.
        if math.random() < 0.5 then
            ent.scaleX = -1
        end
        if math.random() < 0.5 then
            ent.scaleY = -1
        end
    end
})


