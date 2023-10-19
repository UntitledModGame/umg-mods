
local EffectManager = require("shared.effect_manager")



local effects = {}


function effects.addEffect(ent, effectEnt)
    if not ent.effects then
        ent.effects = EffectManager(ent)
    end
    umg.call("effects:addEffect", ent, effectEnt)
    ent.effects:addEffect(effectEnt)
end


function effects.removeEffect(ent, effectEnt)
    if not ent.effects then return end
    umg.call("effects:removeEffect", ent, effectEnt)
    ent.effects:removeEffect(effectEnt)
end



local defineEffectTc = typecheck.assert("string", "table")
function effects.defineEffect(component, effectHandleClass)
    defineEffectTc(component, effectHandleClass)
    --[[
        TODO:
        do some verification here to ensure that effectHandleClass
            is a valid EffectHandle class.
    ]]
    components.project(component, "effect")

    umg.on("effects:addEffect", function(ent, effectEnt)
        if effectEnt[component] then
            -- ensure that `ent` has effectHandler in it's effectManager
        end
    end)
end



return effects

