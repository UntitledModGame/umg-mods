
local Context = require("shared.Context")



umg.defineEntityType("lootplot.main:world", {})


local function createWorld()
    local wEnt = server.entities.world()
    wEnt.x = 0
    wEnt.y = 0

    wEnt.plot = lp.Plot(
        wEnt, 
        lp.main.constants.WORLD_PLOT_SIZE, 
        lp.main.constants.WORLD_PLOT_SIZE
    )

    -- the reason we save Context inside an entity,
    -- is because if we go to save the world, the world-data will be
    -- saved alongside the world-entity.
    wEnt.lootplotContext = Context(wEnt)
    return wEnt
end


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
    plot:foreachInArea(6, 6, 6, 8, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.shop_slot, clientId)
    end)
    plot:foreachInArea(5, 7, 5, 7, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.reroll_button_slot, clientId)
    end)

    -- Start-round button
    plot:foreachInArea(6, 4, 6, 4, function(ppos)
        lp.forceSpawnSlot(ppos, server.entities.next_round_button_slot, clientId)
    end)
end

---@param clientId string
---@param plot lootplot.Plot
local function initializeItems(clientId, plot)
    local dclock = server.entities.doom_clock()
    plot:set(10,4, dclock)
end

umg.on("@createWorld", function()
    local ent = createWorld()
    local clientId = server.getHostClient()
    initializeSlots(clientId, ent.plot)
    initializeItems(clientId, ent.plot)
end)

umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)



umg.on("@tick", function()
    if server then
        if lp.main.isReady() then
            local ctx = lp.main.getContext()
            ctx:sync()
            ctx:tick()
        end
    end
end)

