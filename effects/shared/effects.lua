
local EffectManager = require("shared.effect_manager")

local EventEffectHandler = require("shared.handlers.event_effect_handler")
local QuestionEffectHandler = require("shared.handlers.question_effect_handler")



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



function effects.tryCallEvent(ent, eventName, ...)
    if ent.effects then
        local eventEH = ent.effects:getEffectHandler(EventEffectHandler)
        if eventEH then
            eventEH:call(eventName, ...)
        end
    end
end


function effects.tryAnswerQuestion(ent, questionName, ...)
    do error("nyi") end
    if ent.effects then
        local questionEH = ent.effects:getEffectHandler(QuestionEffectHandler)
        if questionEH then
            questionEH:ask(questionName, ...)
        end
    end
end


return effects

