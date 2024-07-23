

local shouldApplyEffect = require("shared.should_apply")



---@class EventEffects
local EventEffects = objects.Class("effects:EventEffects")



function EventEffects:init(ownerEnt)
    self.ownerEnt = ownerEnt
    self.eventEffects = objects.Set()

    self.eventToEffectSet = {--[[
        Keeps track of what effectEntities are used for each effect.

        [eventName] -> List<effectEnt>
    ]]}
end


local function canTrigger(ownerEnt, effectEnt, ...)
    if not shouldApplyEffect(effectEnt, ownerEnt) then
        return false
    end

    local evEffect = effectEnt.eventEffect
    if evEffect.shouldTrigger then
        return evEffect.shouldTrigger(effectEnt, ownerEnt, ...)
    end
    return true -- all ok!
end


local function activateEffect(ownerEnt, effectEnt, ...)
    local evEffect = effectEnt.eventEffect
    if evEffect.usable and effectEnt.usable then
        umg.melt("todo")
    end

    if evEffect.trigger then
        evEffect.trigger(effectEnt, ownerEnt, ...)
    end

    umg.call("effects:eventEffectTriggered", effectEnt, ownerEnt)
end


function EventEffects:call(eventName, ...)
    local set = self.eventToEffectSet[eventName]
    if not set then
        return -- no events listening. RIP
    end

    local ownerEnt = self.ownerEnt
    for _, effectEnt in ipairs(set) do
        if canTrigger(ownerEnt, effectEnt, ...) then
            activateEffect(ownerEnt, effectEnt, ...)
        end
    end
end



function EventEffects:shouldTakeEffect(effectEnt)
    return effectEnt.eventEffect
end




function EventEffects:addEffect(effectEnt)
    local event = effectEnt.eventEffect.event
    local set = self.eventToEffectSet[event]
    if not set then
        set = objects.Set()
        self.eventToEffectSet[event] = set
    end

    set:add(effectEnt)
end


function EventEffects:removeEffect(effectEnt)
    local event = effectEnt.eventEffect.event
    local set = self.eventToEffectSet[event]
    set:remove(effectEnt)
    if set:size() <= 0 then
        self.eventToEffectSet[event] = nil
    end
end



umg.on("effects:effectAdded", function(effectEnt, ent)
    if effectEnt.eventEffect then
        ent.eventEffects = ent.eventEffects or EventEffects(ent)
        ent.eventEffects:addEffect(effectEnt)
    end
end)


umg.on("effects:effectRemoved", function(effectEnt, ent)
    if ent.eventEffects then
        ent.eventEffects:removeEffect(effectEnt)
    end
end)


