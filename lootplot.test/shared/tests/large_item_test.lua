local testData = require("shared.testData")
local testUtils = require("shared.testUtils")

umg.definePacket("lootplot.test:syncSeed", {typelist = {"number"}})

return function()
    local rng ---@type love.RandomGenerator

    testUtils.addTest("sync_seed", function(self)
        local seed = love.math.random(-2147483648, 2147483647)

        if client then
            client.on("lootplot.test:syncSeed", function(s)
                seed = s
                rng = love.math.newRandomGenerator(seed)
            end)
        end

        self:tick()

        if server then
            rng = love.math.newRandomGenerator(seed)
            server.broadcast("lootplot.test:syncSeed", seed)
        end

        self:tick(2)
        self:assert(rng, "expected rng created, got nil")
        umg.log.info("Using seed "..seed.." for subsequent randomizer.")
    end)

    testUtils.addTest("the_big_item_test", function(self)
        local plot = testUtils.prepare(self, true)

        -- Get all slots
        local slots = {}

        for k, v in pairs((server or client).entities) do
            if v.slot and not v.buttonSlot then
                slots[#slots+1] = {k, v}
            end
        end

        table.sort(slots, function(a, b)
            return a[1] < b[1]
        end)

        -- Spawn all slots
        plot:foreach(function(ppos)
            local slotIndex = rng:random(#slots)

            umg.log.debug("spawning slot", slots[slotIndex][1], "at ppos", tostring(ppos))
            if server then
                lp.forceSpawnSlot(ppos, slots[slotIndex][2])
            end

            self:tick(2)
        end)

        self:tick(10)

        -- Spawn all items
        local query = lp.ITEM_GENERATOR:createQuery(rng):addAllEntries()
        plot:foreach(function(ppos)
            local entry = query()

            umg.log.debug("spawning item", entry, "at ppos", tostring(ppos))
            if server then
                lp.trySpawnItem(ppos, server.entities[entry])
            end

            self:tick(2)
        end)
    end)
end
