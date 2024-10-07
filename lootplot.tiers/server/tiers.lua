
local util = require("shared.util")

local function upgradeTier(ent, sourceEnt)
    local oldTier = ent.tier
    ent.tier = ent.tier + 1
    umg.call("lootplot.tiers:entityUpgraded", ent, sourceEnt, oldTier, ent.tier)
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

