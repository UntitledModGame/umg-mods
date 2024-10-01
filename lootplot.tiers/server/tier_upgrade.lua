
local util = require("shared.util")

local function upgradeTier(ent)
    local oldTier = ent.tier
    ent.tier = ent.tier + 1
    umg.call("lootplot.tiers:entityUpgraded", ent, oldTier, ent.tier)
    sync.syncComponent(ent, "tier")
    lp.tryTriggerEntity("UPGRADE_TIER", ent)
end



umg.on("lootplot:entityActivated", function(ent)
    if not lp.isItemEntity(ent) then
        return
    end

    -- Else, search for matching:
    local ppos = lp.getPos(ent)
    if not ppos then return end

    util.forNeighborItems(ppos, function(targEnt)
        if util.canCombine(ent, targEnt) then
            lp.destroy(targEnt)
            upgradeTier(ent)
        end
    end)
end)

