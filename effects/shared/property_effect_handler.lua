

-- this shouldn't be used outside of `EffectHandler`.
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


local BIG = 0xff

local DEFAULT_MULT = 1
local DEFAULT_MOD = 0
local DEFAULT_MAX = math.huge
local DEFAULT_MIN = -math.huge

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


function PropertyEffectHandler:calculate(ownerEnt)
    for _, effectEnt in ipairs(self.propertyEffects) do
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
end


local function addPropEffect(self, ent, pEffect)
    local prop = pEffect.property
    if pEffect.multiplier then
        self.propertyToModifiers[prop]:add(ent)
    end
end


function PropertyEffectHandler:tryAddEffect(effectEnt)
    if not effectEnt.propertyEffect then
        return
    end
end


return PropertyEffectHandler

