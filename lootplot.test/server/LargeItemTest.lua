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
end

return LargeItemTest
