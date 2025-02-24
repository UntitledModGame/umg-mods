
--[[

LOOTPLOT-attributes

An "Attribute" is a global-ish value,
like `points`, `money`, or `level`.

The reason we do this abstraction here, is because future gamemodes
may not agree on HOW the attrs are stored/handled.

For example:
- Pvp-game:  Each player gets their own money count.
- Cooperative-game:  Money count is fully shared.

^^^ Remember, base-lootplot makes NO ASSUMPTION about the gamemode.


]]


local attributes = {}


---@alias lootplot.AttributeSetter {set: fun(ent:Entity, val:number), get:fun(ent:Entity): number}

---@alias lootplot.AttributeInitArgs { [string]: lootplot.AttributeSetter }


---@type {[string]:number}
local knownAttrs = {--[[
    [attributeName] -> defaultValue
    -- (the value that this attribute starts with)
]]}

---@type {[string]: lootplot.AttributeSetter}
local attributeSetters = nil


local defAttributeTc = typecheck.assert("string", "number")
function attributes.defineAttribute(attr, defaultValue)
    defAttributeTc(attr, defaultValue)
    assert(not knownAttrs[attr], "Redefined existing attribute!")
    knownAttrs[attr] = defaultValue
end

function attributes.getAllAttributes()
    local buf = objects.Array()
    for attr,_ in pairs(knownAttrs) do
        buf:add(attr)
    end
    return buf
end

function attributes.getAttributeDefault(attr)
    return knownAttrs[attr]
end


typecheck.addType("lootplot:attribute", function(x)
    return knownAttrs[x], "Expected attribute"
end)


local attrEntTc = typecheck.assert("lootplot:attribute", "entity")
local attrEntNumberTc = typecheck.assert("lootplot:attribute", "entity", "number")


local function assertServer()
    if not server then
        umg.melt("This can only be called on client-side!", 3)
    end
end


---@param attr string
---@param ent Entity
---@param x number
function attributes.setAttribute(attr, ent, x)
    attrEntNumberTc(attr, ent, x)
    assertServer()
    local oldVal = attributes.getAttribute(attr, ent)
    if oldVal ~= x then
        local delta = x - oldVal
        attributeSetters[attr].set(ent, x)
        umg.call("lootplot:attributeChanged", attr, ent, delta, oldVal, x)
    end
end


--- Sets an attribute without calling callbacks
---@param attr string
---@param ent Entity
---@param x number
function attributes.rawsetAttribute(attr, ent, x)
    attrEntNumberTc(attr, ent, x)
    assertServer()
    local oldVal = attributes.getAttribute(attr, ent)
    if oldVal ~= x then
        attributeSetters[attr].set(ent, x)
    end
end




---@param attr string
---@param ent Entity
---@return number
function attributes.getAttribute(attr, ent)
    attrEntTc(attr, ent)
    return attributeSetters[attr].get(ent)
end

---@param attr string
---@param ent Entity
---@param delta number
function attributes.modifyAttribute(attr, ent, delta)
    attrEntNumberTc(attr, ent, delta)
    local old = attributes.getAttribute(attr, ent)
    attributes.setAttribute(attr, ent, old + delta)
end



local function validSetter(setter)
    return type(setter) == "table" and setter.set and setter.get
end

---@param args lootplot.AttributeInitArgs
function attributes.initialize(args)
    assert(not attributeSetters, "Attempted to initialize twice?")
    attributeSetters = {}
    for attr, setter in pairs(args)do
        assert(attributes.getAttributeDefault(attr), "Invalid attribute: "..tostring(attr))
        attributeSetters[attr] = setter
    end
    for _, attr in ipairs(attributes.getAllAttributes()) do
        local setter = args[attr]
        if not setter then
            umg.melt("Missing attribute definition: " .. tostring(attr))
        end
        if not validSetter(setter) then
            umg.melt("Invalid setter, needs .get and .set function: " .. tostring(setter))
        end
    end
end


return attributes
