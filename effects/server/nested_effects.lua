
--[[

Nested effects

This basically just allows us to compose effects nicely,
which is cool.


]]

require("effect_events")


local effects = require("shared.effects")


umg.on("effects:effectAdded", function(effectEnt, ent)
    if effectEnt.nestedEffect then
        for _, nestedEnt in ipairs(ent.nestedEffect) do
            effects.addEffect(ent, nestedEnt)
        end
    end
end)


umg.on("effects:effectRemoved", function(effectEnt, ent)
    if ent.nestedEffect then
        for _, nestedEnt in ipairs(ent.nestedEffect) do
            effects.removeEffect(ent, nestedEnt)
        end
    end
end)

