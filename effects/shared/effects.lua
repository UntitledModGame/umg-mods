
local EffectManager = require("shared.effect_manager")

local EventEffectHandler = require("shared.default_handlers.event_effect_handler")
local QuestionEffectHandler = require("shared.default_handlers.question_effect_handler")



local effects = {}


if server then
--[[
    server-only API:
]]

function effects.addEffect(ent, effectEnt)
    if not ent.effectManager then
        ent.effectManager = EffectManager(ent)
    end
    ent.effectManager:addEffect(effectEnt)
    server.broadcast("effects.addEffect", ent, effectEnt)
end


function effects.removeEffect(ent, effectEnt)
    if not ent.effectManager then return end
    ent.effectManager:removeEffect(effectEnt)
    server.broadcast("effects.removeEffect", ent, effectEnt)
end

end


if client then
    client.on("effects.addEffect", function(ent, effectEnt)
        ent.effectManager:addEffect(effectEnt)
    end)

    client.on("effects.removeEffect", function(ent, effectEnt)
        ent.effectManager:removeEffect(effectEnt)
    end)
end




local defineEffectTc = typecheck.assert("table")
function effects.defineEffectHandler(effectHandlerClass)
    defineEffectTc(effectHandlerClass)
    EffectManager.defineEffectHandler(effectHandlerClass)
end





local effectManagerGroup = umg.group("effectManager")

umg.on("@tick", function(dt)
    for _, ent in ipairs(effectManagerGroup) do
        ent.effectManager:tick(dt)
    end
end)




--[[


TODO:

Should we go back to our original way of implicitly proxying events?
I feel like that would be cleaner...
instead of doing this weird, manual-call shit with `ask` and `on`.


]]

function effects.tryCallEvent(ent, eventName, ...)
    -- used for eventEffects
    if ent.effectManager then
        local eventEH = ent.effectManager:getEffectHandler(EventEffectHandler)
        if eventEH then
            eventEH:call(eventName, ...)
        end
    end
end


function effects.tryAnswerQuestion(ent, questionName, ...)
    -- used for eventEffects
    do error("nyi") end
    if ent.effectManager then
        local questionEH = ent.effectManager:getEffectHandler(QuestionEffectHandler)
        if questionEH then
            questionEH:ask(questionName, ...)
        end
    end
end



effects.defineEffectHandler(EventEffectHandler)

-- effects.defineEffectHandler(QuestionEffectHandler)


return effects

