
---@meta


assert(not lp.tiers,"?")

lp.tiers = {}


local upgradeTc = typecheck.assert("entity", "entity")
function lp.tiers.upgradeTier(ent, sourceEnt)
    assert(server, "Can only be called on server!")
    upgradeTc(ent, sourceEnt)
    if not lp.tiers.canBeUpgraded(ent) then
        -- cant be upgraded!
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


function lp.tiers.canBeUpgraded(ent)
    return ent.tierUpgrade
end

