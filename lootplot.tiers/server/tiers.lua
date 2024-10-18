
local UPGRADE_TIME = 0.5

umg.on("lootplot:entityActivated", function(ent)
    if not lp.isItemEntity(ent) then
        return
    end
    if not lp.tiers.canBeUpgraded(ent) then
        return
    end

    -- Else, search for matching:
    local ppos = lp.getPos(ent)
    if not ppos then return end

    util.forNeighborItems(ppos, function(targEnt)
        if util.canCombine(ent, targEnt) then
            lp.tiers.upgradeTier(ent, targEnt)
            lp.destroy(targEnt)
            lp.wait(ppos, UPGRADE_TIME)
        end
    end)
end)


umg.on("lootplot:entitySpawned", function(ent)
    -- assign default tier
    ent.tier = ent.tier or 1
end)
