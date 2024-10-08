
local Run = require("shared.Run")


lp.defineAttribute("ROUND")
-- current round number

lp.defineAttribute("NUMBER_OF_ROUNDS")
-- The number of rounds allowed per level
-- (should generally be kept constant.)
-- if ROUND > NUMBER_OF_ROUNDS, lose.

lp.defineAttribute("REQUIRED_POINTS")
-- once we reach this number, we can progress to next level.



--[[
==============================
    World-generation code:
==============================
]]
---@param plot lootplot.Plot
local function initializeSlots(clientId, plot)
    -- adds basic slots to be overridden
    plot:foreachInArea(9, 6, 11, 8, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.slot, clientId)
    end)

    -- Add shop slots + reroll
    plot:foreachInArea(5, 7, 7, 8, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.shop_slot, clientId)
    end)
    lp.forceSpawnSlot(plot:getPPos(6,6), server.entities.reroll_button_slot, clientId)

    -- Sell slots:
    plot:foreachInArea(9, 10, 11, 10, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.sell_slot, clientId)
    end)

end

---@param plot lootplot.Plot
---@param worldEnt Entity
local function initBuiltins(plot, worldEnt)
    local dclock = server.entities.doom_clock()
    dclock._plotX = 10
    dclock._plotY = 4
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local ppos = plot:getPPos(dclock._plotX, dclock._plotY)
    local v = ppos:getWorldPos()
    dclock.x = v.x
    dclock.y = v.y
    dclock.dimension = v.dimension

    local run = worldEnt.lootplotMainRun
    run:setDoomClock(dclock)

    -- Meta-buttons
    lp.forceSpawnSlot(plot:getPPos(6,4), server.entities.next_round_button_slot, clientId)
    lp.forceSpawnSlot(plot:getPPos(7,4), server.entities.next_level_button_slot, clientId)
end

if server then

umg.on("@load", function()
    local ent = Run()
    local clientId = server.getHostClient()
    initializeSlots(clientId, ent.plot)
    initBuiltins(ent.plot, ent)
end)

end

umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)



umg.on("@tick", function()
    if server then
        if lp.main.isReady() then
            local ctx = lp.main.getRun()
            ctx:sync()
            ctx:tick()
        end
    end
end)



local r = lp.rarities
lp.rarities.configureLevelSpawningLimits({
    -- Rare items can only spawn after level 3.
    -- epic items after level 5... etc etc.
    [r.RARE] = 3,
    [r.EPIC] = 5,
    [r.LEGENDARY] = 9,
    [r.MYTHIC] = 14,
})
