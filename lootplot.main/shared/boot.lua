
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
local function addBaseSlots(plot)
    -- adds basic slots to be overridden
    plot:foreachInArea(9,11, 4,6, function(ppos)
        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
        lp.trySpawnItem(ppos, server.entities.bb)
    end)
end
local function addShopSlots(plot)
    plot:foreachInArea(4,6, 6,7, function(ppos)
        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end



umg.on("@createWorld", function()
    local ent = createWorld()
    addBaseSlots(ent.plot)
    addShopSlots(ent.plot)
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

