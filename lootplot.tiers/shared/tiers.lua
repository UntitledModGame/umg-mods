
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
    local upgradeFunc = ent.tierUpgrade.upgrade
    if upgradeFunc then
        upgradeFunc(ent, sourceEnt, oldTier, ent.tier)
    end
    sync.syncComponent(ent, "tier")
    lp.tryTriggerEntity("UPGRADE_TIER", ent)
end


function lp.tiers.getTier(ent)
    return ent.tier or 1
end


local MAX_TIER = 5
---@param combineEnt Entity
---@param targetEnt Entity
---@return boolean
function lp.tiers.canUpgrade(combineEnt, targetEnt)
    if not (hasUpgrade(combineEnt) and hasUpgrade(targetEnt)) then
        return false
    end

    if (combineEnt:type() == targetEnt:type()) and (combineEnt.tier == targetEnt.tier) then
        -- limit to tier 5
        return combineEnt.tier < MAX_TIER and targetEnt.tier < MAX_TIER
    end
    return false
end


umg.answer("lootplot:canCombineItems", lp.tiers.canUpgrade)


if server then
local UPGRADE_TIME = 0.5


umg.on("lootplot:itemsCombined", function(combineEnt, targetEnt)
    if lp.tiers.canUpgrade(combineEnt, targetEnt) then
        lp.tiers.upgradeTier(targetEnt, combineEnt)
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

