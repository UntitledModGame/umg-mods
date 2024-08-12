
local TestContext = require("shared.TestContext")
local testData = require("shared.testData")

umg.defineEntityType("lootplot.test:world", {})

local function createWorld()
    local wEnt = server.entities.world()
    wEnt.x = 0
    wEnt.y = 0

    wEnt.plot = lp.Plot(wEnt, testData.getPlotDimensions())

    -- the reason we save Context inside an entity,
    -- is because if we go to save the world, the world-data will be
    -- saved alongside the world-entity.
    wEnt.lootplotContext = TestContext(wEnt)
    return wEnt
end

umg.on("@createWorld", createWorld)

umg.on("@playerJoin", function(clientId)
    local w, h = testData.getPlotDimensions()
    local p = server.entities.player(clientId)
    local context = testData.getContext()
    local plot = context.ownerEnt.plot ---@type lootplot.Plot
    local ppos = lp.PPos({slot = plot:coordsToIndex(math.floor(w / 2), math.floor(h / 2)), plot = plot})
    local dvec = plot:pposToWorldCoords(ppos)
    testData.setPlayer(p)
    p.x, p.y = dvec.x, dvec.y
    p.moveX, p.moveY = 0, 0
end)

umg.on("@tick", function()
    if server then
        local ctx = testData.getContext()

        if ctx then
            ctx:sync()
            ctx:tick()
        end
    end
end)
