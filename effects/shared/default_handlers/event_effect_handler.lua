

local effects = require("shared.effects")


local EventEffectHandler = objects.Class("effects:EventEffectHandler")



function EventEffectHandler:init(activeEffects)
    -- activeEffects is passed in from `EffectHandler`.
    self.activeEffects = activeEffects

    self.eventEffects = objects.Set()

    self.eventToEffectList = {--[[
        Keeps track of what effectEntities are used for each effect.

        [eventName] -> List<effectEnt>
    ]]}
end


function EventEffectHandler:addEffect(effectEnt)
    local 
end


function EventEffectHandler:removeEffect(effectEnt)

end


function EventEffectHandler:shouldTakeEffect(effectEnt)
    return effectEnt.eventEffect
end




local listenedEvents = {--[[
    Checks whether we already have a listener setup for this event

    [eventName] -> true
]]}



local function ensureEventListener(eventName)
    --[[
        creates an event-listener for `eventName` at runtime,
        (if one doesn't already exist.)

        This function only works when the effect entity is
            the first argument passed into the event.
    ]]
    if listenedEvents[eventName] then
        return
    end

    umg.on(eventName, function(ent, ...)
        if ent.effects then
            local eventEH = ent.effects:getEffectHandler(EventEffectHandler) 
            if eventEH then
                eventEH
            end
        end
    end)

    listenedEvents[eventName] = true
end


function EventEffectHandler:addEffect()

end


effects.defineEffectHandler(EventEffectHandler)


