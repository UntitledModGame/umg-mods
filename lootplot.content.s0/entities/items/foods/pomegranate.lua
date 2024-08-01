
lp.defineItem("lootplot.content.s0:pomegranate", {
    image = "pomegranate",

    name = localization.localize("pomegranate"),
    targetActivationDescription = localization.localize("Generates normal slots"),
    doomCount = 1,
    baseBuyPrice = 5,

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetShape = lp.targets.PlusShape(1),

    targetType = "NO_SLOT",
    activateTargets = function(ent, ppos, targetEnt)
        local e = lp.trySpawnSlot(ppos, server.entities.slot)
        if e then

            --[[
                TODO: THIS IS ABSOLUTE DOG WATER!
                We shouldn't be setting .ownerPlayer component in here.
                There should be an easier api to automatically inherit, or something.

                We should make it as easy as possible to spawn items and slots.
            ]]
            e.ownerPlayer = ent.ownerPlayer
        end
    end,
})


