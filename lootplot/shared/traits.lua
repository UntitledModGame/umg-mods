

local validTraits = {}

local traits = {}
local traitNames = {}



local function ensureHasTraits(ent)
    if not ent.traits then
        if ent.baseTraits then
            -- copy from parent etype:
            ent.traits = objects.Set(ent.baseTraits)
        else
            -- else empty
            ent.traits = objects.Set()
        end
    end
end


local baseTraitGroup = umg.group("baseTraits")
baseTraitGroup:onAdded(ensureHasTraits)


typecheck.addType("lootplot:trait", function (x)
    return validTraits[x], "Expected lootplot trait"
end)

local ttc = typecheck.assert("entity", "lootplot:trait")

---@param ent Entity
---@param trait string
function traits.addTrait(ent, trait)
    ttc(ent, trait)
    ensureHasTraits(ent)
    ent.traits:add(trait)
    umg.call("lootplot:traitAdded", ent, trait)
end

---@param ent Entity
---@param trait string
function traits.removeTrait(ent, trait)
    ttc(ent, trait)
    ensureHasTraits(ent)
    if ent.traits:has(trait) then
        ent.traits:remove(trait)
        umg.call("lootplot:traitRemoved", ent, trait)
    end
end

---@param ent Entity
---@param trait string
---@return boolean
function traits.hasTrait(ent, trait)
    ttc(ent, trait)
    return ent.traits:has(trait)
end

---@param traitName string
---@param displayName string
function traits.defineTrait(traitName, displayName)
    validTraits[traitName] = true
    traitNames[traitName] = displayName
end


local displayNameTc = typecheck.assert("lootplot:trait")

---@param traitName string
---@return string
function traits.getDisplayName(traitName)
    displayNameTc(traitName)
    return assert(traitNames[traitName])
end


return traits
