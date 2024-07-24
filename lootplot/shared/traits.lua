

local validTraits = {}

local traits = {}



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


function traits.addTrait(ent, trait)
    ttc(ent, trait)
    ensureHasTraits(ent)
    ent.traits:add(trait)
    umg.call("lootplot:traitAdded", ent, trait)
end


function traits.removeTrait(ent, trait)
    ttc(ent, trait)
    ensureHasTraits(ent)
    if ent.traits:has(trait) then
        ent.traits:remove(trait)
        umg.call("lootplot:traitRemoved", ent, trait)
    end
end


function traits.hasTrait(ent, trait)
    ttc(ent, trait)
    return ent.traits:has(trait)
end


function traits.defineTrait(traitName)
    validTraits[traitName] = true
end



return traits
