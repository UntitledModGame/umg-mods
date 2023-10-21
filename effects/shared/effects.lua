
local EffectManager = require("shared.effect_manager")



local effects = {}


function effects.addEffect(ent, effectEnt)
    if not ent.effects then
        ent.effects = EffectManager(ent)
    end
    ent.effects:addEffect(effectEnt)
end


function effects.removeEffect(ent, effectEnt)
    if not ent.effects then return end
    ent.effects:removeEffect(effectEnt)
end



local defineEffectTc = typecheck.assert("table")
function effects.defineEffectHandler(effectHandlerClass)
    defineEffectTc(effectHandlerClass)
    EffectManager.defineEffectHandler(effectHandlerClass)
end



return effects

