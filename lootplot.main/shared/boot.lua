
local Run = require("shared.Run")


lp.defineAttribute("ROUND")
-- current round number

lp.defineAttribute("NUMBER_OF_ROUNDS")
-- The number of rounds allowed per level
-- (should generally be kept constant.)
-- if ROUND > NUMBER_OF_ROUNDS, lose.

lp.defineAttribute("REQUIRED_POINTS")
-- once we reach this number, we can progress to next level.



---@param plot lootplot.Plot
local function initBuiltins(plot)
    local dclock = server.entities.doom_clock()
    dclock._plotX = 10
    dclock._plotY = 4
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local ppos = plot:getPPos(dclock._plotX, dclock._plotY)
    local dvec = ppos:getWorldPos()
    dclock.x = dvec.x
    dclock.y = dvec.y
    dclock.dimension = dvec.dimension

    -- Meta-buttons
    lp.forceSpawnSlot(plot:getPPos(6,4), server.entities.next_round_button_slot, clientId)
    lp.forceSpawnSlot(plot:getPPos(7,4), server.entities.next_level_button_slot, clientId)
end

if server then

umg.on("@load", function()
    ---@type lootplot.main.Run
    local run = Run()
    local plot = run:getPlot()

    -- TODO: Extract this into its own lil thing
    local mid = math.floor(lp.main.constants.WORLD_PLOT_SIZE/2)
    local team = server.getHostClient()
    local midPos = plot:getPPos(mid, mid)
    lp.forceSpawnSlot(midPos, server.entities.slot, team)
    lp.forceSpawnItem(midPos, server.entities.one_ball, team)

    initBuiltins(plot)
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
