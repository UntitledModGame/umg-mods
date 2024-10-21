
---@meta


assert(not lp.tiers,"?")

lp.tiers = {}


local function hasUpgrade(ent)
    return ent.tierUpgrade
end


local upgradeTc = typecheck.assert("entity", "entity")
function lp.tiers.upgradeTier(ent, sourceEnt)
    assert(server, "Can only be called on server!")
    upgradeTc(ent, sourceEnt)
    if not hasUpgrade(ent) then
        return
    end
    local oldTier = ent.tier
    ent.tier = ent.tier + 1
    umg.call("lootplot.tiers:entityUpgraded", ent, sourceEnt, oldTier, ent.tier)
    if type(ent.tierUpgrade) == "function" then
        ent:tierUpgrade(sourceEnt, oldTier, ent.tier)
    end
    sync.syncComponent(ent, "tier")
    lp.tryTriggerEntity("UPGRADE_TIER", ent)
end



local function canUpgrade(combineEnt, targetEnt)
    if not (hasUpgrade(combineEnt) and hasUpgrade(targetEnt)) then
        return false
    end
    if (combineEnt:type() == targetEnt:type()) and (combineEnt.tier == targetEnt.tier) then
        return true
    end
    return false
end

umg.answer("lootplot:canCombineItems", function(itemA, itemB)
    return canUpgrade(itemA, itemB)
end)


if server then
local UPGRADE_TIME = 0.5


umg.on("lootplot:itemsCombined", function(combineEnt, targetEnt)
    if canUpgrade(combineEnt, targetEnt) then
        lp.tiers.upgradeTier(combineEnt, targetEnt)
        lp.destroy(combineEnt)
        local ppos = lp.getPos(targetEnt)
        if ppos then
            lp.wait(ppos, UPGRADE_TIME)
        end
    end
end)



umg.on("lootplot:entitySpawned", function(ent)
    -- assign default tier
    ent.tier = ent.tier or 1
end)

end

