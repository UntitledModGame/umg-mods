

local effects = require("shared.effects")


local EventEffectHandler = objects.Class("effects:EventEffectHandler")



function EventEffectHandler:init(activeEffects)
    -- activeEffects is passed in from `EffectHandler`.
    self.activeEffects = activeEffects

    self.eventEffects = objects.Set()

    self.eventToEffectSet = {--[[
        Keeps track of what effectEntities are used for each effect.

        [eventName] -> List<effectEnt>
    ]]}
end



function EventEffectHandler:shouldTakeEffect(effectEnt)
    return effectEnt.eventEffect
end




local listenedEvents = {--[[
    Checks whether we already have a listener setup for this event

    [eventName] -> true
]]}


local function tryCallEvent(ent, eventName)
    if ent.effects then
        local eventEH = ent.effects:getEffectHandler(EventEffectHandler) 
        if eventEH then
            eventEH:call(eventName)
        end
    end
end


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

    umg.on(eventName, function(ent)
        tryCallEvent(ent, eventName)
    end)

    listenedEvents[eventName] = true
end



function EventEffectHandler:addEffect(effectEnt)
    local event = effectEnt.event
    local set = self.eventToEffectSet[event]
    if not set then
        set = objects.Set()
        self.eventToEffectSet[event] = set
    end

    ensureEventListener(event)
    set:add(effectEnt)
end


function EventEffectHandler:removeEffect(effectEnt)
    local event = effectEnt.event
    local set = self.eventToEffectSet[event]
    set:remove(effectEnt)
end





effects.defineEffectHandler(EventEffectHandler)


