

local effects = require("shared.effects")


local PropertyEffects = objects.Class("effects:PropertyEffects")


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


function PropertyEffects:init()
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

local function calculate(val, effectEnt, ownerEnt)
    -- `val` is either a function that generates a value,
    -- or a value upon itself.
    if type(val) == "function" then
        return val(effectEnt, ownerEnt)
    end
    return val
end


local function pollPropEffect(self, effectEnt, ownerEnt, pEffect)
    local modifiers = self.modifiers
    local multipliers = self.multipliers
    local minClamps = self.minClamps
    local maxClamps = self.maxClamps
    local prop = pEffect.property

    if pEffect.modifier then
        modifiers[prop] = modifiers[prop] + calculate(pEffect.modifier, effectEnt, ownerEnt)
    end

    if pEffect.multiplier then
        multipliers[prop] = multipliers[prop] * calculate(pEffect.multiplier, effectEnt, ownerEnt)
    end

    if pEffect.min then
        minClamps[prop] = math.max(minClamps[prop], calculate(pEffect.min, effectEnt, ownerEnt))
    end

    if pEffect.max then
        maxClamps[prop] = math.min(maxClamps[prop], calculate(pEffect.max, effectEnt, ownerEnt))
    end
end


local function pollEffectEnt(self, effectEnt, ownerEnt)
    local comp = effectEnt.propertyEffect
    if comp.property then
        -- `comp` is a property-effect!
        -- (this occurs when the entity only has 1 propertyEffect.)
        pollPropEffect(self, effectEnt, ownerEnt, comp)
    end

    for _, pEffect in ipairs(comp) do
        pollPropEffect(self, effectEnt, ownerEnt, pEffect)
    end
end


local function clearPropertyBuffer(buffer)
    for prop,_ in pairs(buffer) do
        buffer[prop] = nil
    end
end

local function clearBuffers(self)
    clearPropertyBuffer(self.multipliers)
    clearPropertyBuffer(self.modifiers)
    clearPropertyBuffer(self.maxClamps)
    clearPropertyBuffer(self.minClamps)
end


function PropertyEffects:tick(ownerEnt)
    for _, ent in ipairs(self.propertyEffects) do
        if (not umg.exists(ent)) or (not self.activeEffects:contains(ent)) then
            self.propertyEffects:remove(ent)
        end
    end

    --[[
        TODO: This is kinda slow and dumb. Maybe think of a better way?
        (It's actually not TOOOO slow, but like, its dumb lol)
    ]]
    clearBuffers(self)

    for _, effectEnt in ipairs(self.propertyEffects) do
        pollEffectEnt(self, effectEnt, ownerEnt)
    end
end


function PropertyEffects:addEffect(effectEnt)
    self.propertyEffects:add(effectEnt)
end

function PropertyEffects:removeEffect(effectEnt)
    self.propertyEffects:remove(effectEnt)
end


function PropertyEffects:getModifier(property)
    return self.modifiers[property]
end

function PropertyEffects:getMultiplier(property)
    print("mult:",self.multipliers[property])
    return self.multipliers[property]
end

function PropertyEffects:getMaxClamp(property)
    return self.maxClamps[property]
end

function PropertyEffects:getMinClamp(property)
    return self.minClamps[property]
end


function PropertyEffects:shouldTakeEffect(effectEnt)
    return effectEnt.propertyEffect
end



local function getPropertyEffectHandler(ent)
    local eManager = ent.effectManager
    if eManager then
        local propEH = eManager:getEffectHandler(PropertyEffects) 
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





umg.on("effects:effectAdded", function(effectEnt, ent)
    if effectEnt.propertyEffect then
        ent.propertyEffects = ent.propertyEffects or PropertyEffects()
    end
    ent.propertyEffects:addEffect(effectEnt)
end)


umg.on("effects:effectRemoved", function(effectEnt, ent)
    if ent.propertyEffects then
        ent.propertyEffects:removeEffects(effectEnt)
    end
end)




local effectManagerGroup = umg.group("propertyEffects")

umg.on("@tick", function(dt)
    for _, ent in ipairs(effectManagerGroup) do
        ent.propertyEffects:tick(dt)
    end
end)

