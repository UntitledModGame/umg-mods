
local util = require("shared.util")



local function upgradeProperty(ent, prop, propVals, newTier)
    local baseProp = properties.getBase(prop)
    if baseProp then
        ent[baseProp] = propVals[newTier]
        sync.syncComponent(ent, baseProp)
    else
        umg.log.error("Invalid property:", prop)
    end
end


local function upgradeStats(ent, sourceEnt, oldTier, newTier)
    local m = ent.tierUpgrades

    m.onUpgrade(ent, sourceEnt, oldTier, newTier)

    if m.properties then
        for prop,propVals in pairs(m.properties) do
            if propVals[newTier] then
                upgradeProperty(ent, prop, propVals, newTier)
            end
        end
    end
end



local function upgradeTier(ent, sourceEnt)
    local oldTier = ent.tier
    ent.tier = ent.tier + 1
    umg.call("lootplot.tiers:entityUpgraded", ent, sourceEnt, oldTier, ent.tier)
    if ent.upgradeManager then
        upgradeStats(ent, ent.upgradeManager)
    end
    sync.syncComponent(ent, "tier")
    lp.tryTriggerEntity("UPGRADE_TIER", ent)
end



local UPGRADE_TIME = 0.5

umg.on("lootplot:entityActivated", function(ent)
    if not lp.isItemEntity(ent) then
        return
    end

    -- Else, search for matching:
    local ppos = lp.getPos(ent)
    if not ppos then return end

    util.forNeighborItems(ppos, function(targEnt)
        if util.canCombine(ent, targEnt) then
            upgradeTier(ent, targEnt)
            lp.destroy(targEnt)
            lp.wait(ppos, UPGRADE_TIME)
        end
    end)
end)




umg.on("lootplot:entitySpawned", function(ent)
    -- assign default tier
    ent.tier = ent.tier or 1
end)

