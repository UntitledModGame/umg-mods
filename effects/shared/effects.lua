
local EffectManager = require("shared.effect_manager")

local EventEffectHandler = require("shared.default_handlers.event_effect_handler")
local QuestionEffectHandler = require("shared.default_handlers.question_effect_handler")



local effects = {}


if server then
--[[
    server-only API:
]]

function effects.addEffect(ent, effectEnt)
    if not ent.effects then
        ent.effects = objects.Set()
    end
    if ent.effects:has(effectEnt) then
        return -- already has effect
    end
    ent.effects:add(effectEnt)
    umg.call("effects:effectAdded", effectEnt, ent)

    if server then
        server.broadcast("effects.addEffect", ent, effectEnt)
    end
end


function effects.removeEffect(ent, effectEnt)
    if not ent.effects then
        return -- no effects
    end
    if not ent.effects:has(effectEnt) then
        return -- doesnt have effect in question
    end

    ent.effects:remove(effectEnt)
    umg.call("effects:effectRemoved", effectEnt, ent)
    if ent.effects:size() <= 0 then
        ent:removeComponent("effects")
    end
    
    if server then
        server.broadcast("effects.removeEffect", ent, effectEnt)
    end
end

end


if client then
    client.on("effects.addEffect", function(ent, effectEnt)
        effects.addEffect(ent, effectEnt)
    end)

    client.on("effects.removeEffect", function(ent, effectEnt)
        effects.removeEffect(ent, effectEnt)
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

