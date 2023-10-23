

local effects = require("shared.effects")


local PropertyEffectHandler = objects.Class("effects:PropertyEffectHandler")


local function makeWithDefaultValue(defaultValue)
    --[[
        creates a table that returns a default value
        if the value is not found.
    ]]
    return setmetatable({}, {
        __index = function(t,k)
            return defaultValue
        end
    })
end


function PropertyEffectHandler:init(activeEffects)
    -- activeEffects is passed in from `EffectHandler`.
    self.activeEffects = activeEffects

    self.propertyEffects = objects.Set()

    self.modifiers = makeWithDefaultValue(0 --[[
        [property] = cachedModifier
        Modifiers are recalculated per-tick.
        (This just serves as an internal cache)
    ]])
    self.multipliers = makeWithDefaultValue(1 --[[
        [property] = cachedMultiplier
        Multipliers are recalculated per-tick.
        (Same as above; internal cache)
    ]])
    self.maxClamps = makeWithDefaultValue(math.huge --[[
        [property] = cachedMaxClamp
        recalculated per-tick.
    ]])
    self.minClamps = makeWithDefaultValue(-math.huge --[[
        [property] = cachedMinClamp
        recalculated per-tick.
    ]])
end


local type = type

local function calculate(val, ent, ownerEnt)
    -- `val` is either a function that generates a value,
    -- or a value upon itself.
    if type(val) == "function" then
        return val(ent, ownerEnt)
    end
    return val
end


local function pollPropEffect(self, ent, ownerEnt, pEffect)
    local modifiers = self.modifiers
    local multipliers = self.multipliers
    local minClamps = self.minClamps
    local maxClamps = self.maxClamps
    local prop = pEffect.property

    if pEffect.modifier then
        modifiers[prop] = modifiers[prop] + calculate(pEffect.modifier, ent, ownerEnt)
    end

    if pEffect.multiplier then
        multipliers[prop] = multipliers[prop] * calculate(pEffect.multiplier, ent, ownerEnt)
    end

    if pEffect.min then
        minClamps[prop] = math.max(minClamps[prop], calculate(pEffect.min, ent, ownerEnt))
    end

    if pEffect.max then
        maxClamps[prop] = math.min(maxClamps[prop], calculate(pEffect.max, ent, ownerEnt))
    end
end


local function pollEffectEnt(self, effectEnt, ownerEnt)
    local arr = effectEnt.propertyEffect
    if arr.property then
        -- `arr` is a property-effect!
        -- (this occurs when the entity only has 1 propertyEffect.)
        pollPropEffect(self, effectEnt, ownerEnt, arr)
    end

    for _, pEffect in ipairs(arr) do
        pollPropEffect(self, effectEnt, ownerEnt, pEffect)
    end
end


function PropertyEffectHandler:tick(ownerEnt)
    for _, ent in ipairs(self.propertyEffects) do
        if (not umg.exists(ent)) or (not self.activeEffects:contains(ent)) then
            self.propertyEffects:remove(ent)
        end
    end

    for _, effectEnt in ipairs(self.propertyEffects) do
        pollEffectEnt(self, effectEnt, ownerEnt)
    end
end


function PropertyEffectHandler:addEffect(effectEnt)
    self.propertyEffects:add(effectEnt)
end

function PropertyEffectHandler:removeEffect(effectEnt)
    self.propertyEffects:remove(effectEnt)
end


function PropertyEffectHandler:getModifier(property)
    return self.modifiers[property]
end

function PropertyEffectHandler:getMultiplier(property)
    return self.multipliers[property]
end

function PropertyEffectHandler:getMaxClamp(property)
    return self.maxClamps[property]
end

function PropertyEffectHandler:getMinClamp(property)
    return self.minClamps[property]
end


function PropertyEffectHandler:shouldTakeEffect(effectEnt)
    return effectEnt.propertyEffect
end



local function getPropertyEffectHandler(ent)
    local eManager = ent.effects
    if eManager then
        local propEH = eManager:getEffectHandler(PropertyEffectHandler) 
        if propEH then
            return propEH
        end
    end
end


--[[
    now, actually apply the property transformations:
    This is efficient "enough"
]]
umg.answer("properties:getPropertyMultiplier", function(ent, property)
    local propEH = getPropertyEffectHandler(ent)
    if propEH then
        return propEH:getMultiplier(property)
    end
end)


umg.answer("properties:getPropertyModifier", function(ent, property)
    local propEH = getPropertyEffectHandler(ent)
    if propEH then
        return propEH:getModifier(property)
    end
end)


umg.answer("properties:getPropertyClamp", function(ent, property)
    local propEH = getPropertyEffectHandler(ent)
    if propEH then
        return propEH:getMinClamp(property), propEH:getMaxClamp(property)
    end
end)




effects.defineEffectHandler(PropertyEffectHandler)

