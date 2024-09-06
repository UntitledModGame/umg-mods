local testData = require("shared.testData")

---@class lootplot.test.LargeItemTest: objects.Class
local LargeItemTest = objects.Class("lootplot.test:LargeItemTest")

---@param plot lootplot.Plot
function LargeItemTest:init(plot)
    local seed = love.math.random(-2147483648, 2147483647)
    umg.log.info("Using seed "..seed.." for large item testing")

    self.rng = love.math.newRandomGenerator(seed)
    self.plot = plot
end

function LargeItemTest:setup()
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
    self.plot:foreach(function(ppos)
        local slotIndex = self.rng:random(#slots)

        umg.log.debug("spawning slot", slots[slotIndex][1], "at ppos", tostring(ppos))
        lp.forceSpawnSlot(ppos, slots[slotIndex][2])
    end)

    local itemGen = lp.newItemGenerator()
    -- Spawn all items
    self.plot:foreach(function(ppos)
        local entry = itemGen:query()

        umg.log.debug("spawning item", entry, "at ppos", tostring(ppos))
        if server then
            lp.trySpawnItem(ppos, server.entities[entry])
        end
    end)
end

function LargeItemTest:canActivateItem()
    return testData.getContext():getPlot().pipeline:isEmpty()
end

function LargeItemTest:activateItems()
    -- Pick random PPos
    local w, h = testData.getPlotDimensions()
    local x, y, ppos
    repeat
        x = self.rng:random(0, w - 1)
        y = self.rng:random(0, h - 1)
        ppos = lp.PPos({slot = self.plot:coordsToIndex(x, y), plot = self.plot})
    until lp.posToSlot(ppos)

    umg.log.info("Attempt to trigger slot at "..tostring(ppos))
    lp.Bufferer()
        :all(ppos:getPlot())
        :to("SLOT") -- ppos-->slot
        :withDelay(0.5)
        :execute(function(_ppos, slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end

return LargeItemTest
