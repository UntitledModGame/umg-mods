---Availability: Client and Server
---@class properties
local properties = {}
if false then
    _G.properties = properties
end

---@class property._CommonConfig: table
---@field public base string Reference to the base component.
---@field public requiredComponents string[]?
---@field public shouldComputeClientside boolean? (default false)
---@field public skips integer Only compute the properly after `skips` ticks passed? (default 1)
---@field public onRecalculate? fun(ent:Entity)

---@class property.NumberPropertyConfig: property._CommonConfig
---@field public default number? Default value of the property (default 0).
---@field public getModifier? fun(ent:Entity):number
---@field public getMultiplier? fun(ent:Entity):number

---@class property.BooleanPropertyConfig: property._CommonConfig
---@field public default boolean? Default value of the property (default false).

---@alias property._AnyConfig property.NumberPropertyConfig|property.BooleanPropertyConfig

---@class property._Config: table
---@field package type "number"|"boolean"
---@field package config property._AnyConfig



local propertyToConfig = {--[[
    [propertyName] -> config
]]}
---@cast propertyToConfig table<string, property._Config>



---@param property string
local function getConfig(property)
    return propertyToConfig[property]
end

---@param property string
---@return boolean,string
local function isProperty(property)
    return (not not propertyToConfig[property]), "expected property"
end

typecheck.addType("property", isProperty)






---@param ent Entity
---@param config property.NumberPropertyConfig
---@return number
local function getNumberBaseValue(ent, config)
    local baseProperty = config.base
    if baseProperty and ent[baseProperty] then
        return ent[baseProperty]
    end
    return config.default or 0
end

---@param ent Entity
---@param config property.BooleanPropertyConfig
---@return boolean
local function getBooleanBaseValue(ent, config)
    local baseProperty = config.base
    if ent:hasComponent(baseProperty) then
        return ent[baseProperty]
    end

    return config.default or false
end

---@param ent Entity
---@param property string
local function getMultiplier(ent, property)
    return umg.ask("properties:getPropertyMultiplier", ent, property) or 1
end

---@param ent Entity
---@param property string
local function getModifier(ent, property)
    return umg.ask("properties:getPropertyModifier", ent, property) or 0
end

local DEFAULT_MAX = 2^31-1
local DEFAULT_MIN = -2^31

---@param ent Entity
---@param property string
---@return number,number
local function getClamp(ent, property)
    -- the min/max a property value can take
    local min, max = umg.ask("properties:getPropertyClamp", ent, property)
    min = min or DEFAULT_MIN
    max = max or DEFAULT_MAX
    max = math.max(max, min) -- max cant be smaller than min.
    return min, max
end

---@param ent Entity
---@param property string
---@param config property.NumberPropertyConfig
local function computeNumberProperty(ent, property, config)
    local multiplier = 1 -- multiplicative modifier
    local modifier = getNumberBaseValue(ent, config) -- additive modifier

    if config.getMultiplier then
        multiplier = multiplier * (config.getMultiplier(ent) or 1)
    end
    if config.getModifier then
        modifier = modifier + (config.getModifier(ent) or 0)
    end

    multiplier = multiplier * getMultiplier(ent, property)
    modifier = modifier + getModifier(ent, property)

    local value = modifier * multiplier
    local min, max = getClamp(ent, property)

    return math.clamp(value, min, max), modifier, multiplier, min, max
end



---@param ent Entity
---@param property string
---@param config property.BooleanPropertyConfig
local function computeBooleanProperty(ent, property, config)
    local value = not not getBooleanBaseValue(ent, config)
    return value and umg.ask("properties:getBooleanPropertyValue", ent, property)
end



local EMPTY = {}

---@param comp string
---@param config property._CommonConfig
---@return EntityClass|table<string, any>[]|EntityGroupClass
local function makeGroup(comp, config)
    local extraComps = config.requiredComponents or EMPTY
    return umg.group(comp, unpack(extraComps))
end


local function makeBasePropertyGroup(property)
    assert(server,"?")
    local config = getConfig(property)
    local propcfg = config.config
    if not propcfg.base then
        return -- no base property! return
    end

    -- the "base" value of the property for the entity.
    -- for example, `baseDamage`
    local baseProperty = propcfg.base
    local group = makeGroup(baseProperty, propcfg)

    group:onAdded(function(ent)
        -- all entities with [baseProperty] component get given the property
        if type(ent[baseProperty]) ~= config.type then
            umg.melt(baseProperty .. " component needs to be a ".. config.type .. ". Not the case for: " .. ent:type())
        end
        ent[property] = ent[baseProperty]
    end)
end




local tickEvent
if server then
    tickEvent = "@tick"
elseif client then
    tickEvent = "@update"
end

local computePropertyFunction = {
    number = computeNumberProperty,
    boolean = computeBooleanProperty
}

---@param group EntityGroup
---@param property string
---@param type "number"|"boolean"
---@param config property._AnyConfig
local function updateGroup(group, property, type, config)
    -- updates all entities in a group:
    for _, ent in ipairs(group) do
        ent[property] = computePropertyFunction[type](ent, property, config)
    end
end

local function makePropertyGroup(property)
    local propconfig = getConfig(property)
    local config = propconfig.config
    local group = makeGroup(property, config)

    local count = 1
    umg.on(tickEvent, function()
        local skips = config.skips or 1
        count = count + 1

        -- only update after we have skipped `skips` times.
        -- This allows us to make property calculation more "lazy"
        if count > skips then
            updateGroup(group, property, propconfig.type, config)
            count = 1
        end
    end)
end


---@param property string
---@param type "number"|"boolean"
---@param config property._AnyConfig
local function defineProperty(property, type, config)
    if propertyToConfig[property] then
        umg.melt("Property is already defined: " .. tostring(property))
    end

    propertyToConfig[property] = {type = type, config = config}

    if server then
        makeBasePropertyGroup(property)
        makePropertyGroup(property)
    elseif client then
        if config.shouldComputeClientside then
            makePropertyGroup(property)
        end
    end
end




local numberConfigTableType = {
    base = "string",
    default = "number?",
    requiredComponents = "table?",
    shouldComputeClientside = "boolean?",
    skips = "number?",

    getModifier = "function?",
    getMultiplier = "function?",

    onRecalculate = "function?"
}
local defineNumberTc = typecheck.assert("string", numberConfigTableType)

---Defines a number property
---@param property string
---@param config property.NumberPropertyConfig
function properties.defineNumberProperty(property, config)
    defineNumberTc(property, config)
    return defineProperty(property, "number", config)
end




local booleanConfigTableType = {
    base = "string",
    default = "boolean?",
    requiredComponents = "table?",
    shouldComputeClientside = "boolean?",
    skips = "number?",
    onRecalculate = "function?"
}
local defineBooleanTc = typecheck.assert("string", booleanConfigTableType)

---Defines a boolean property
---@param property string
---@param config property.BooleanPropertyConfig
function properties.defineBooleanProperty(property, config)
    defineBooleanTc(property, config)
    return defineProperty(property, "boolean", config)
end




local computeTc = typecheck.assert("entity", "property")

---Computes a property
---@param ent Entity
---@param property string
---@return boolean|number
function properties.computeProperty(ent, property)
    computeTc(ent, property)
    local config = propertyToConfig[property]
    return computePropertyFunction[config.type](ent, property, config.config)
end



local propTc = typecheck.assert("property")

---Gets the default value of a property
---@param property string
---@return boolean|number
function properties.getDefault(property)
    propTc(property)
    local config = propertyToConfig[property]

    if config.type == "boolean" then
        return config.config.default or false
    else
        return config.config.default or 0
    end
end


---Gets the base property (e.g. maxHealth -> baseMaxHealth)
---@param property string
---@return string?
function properties.getBase(property)
    local config = propertyToConfig[property]
    if config and config.config.base then
        return config.config.base
    end
end


---@return string[]
function properties.getAllProperties()
    local result = {}

    for k in pairs(propertyToConfig) do
        result[#result+1] = k
    end

    return result
end



---Gets property type (or `nil` if property doesn't exist)
---@param property string
---@return "boolean"|"number"|nil
function properties.getPropertyType(property)
    local config = propertyToConfig[property]

    if config then
        return config.type
    end
end

umg.expose("properties", properties)
return properties
