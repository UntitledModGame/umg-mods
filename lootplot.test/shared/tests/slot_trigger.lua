local testData = require("shared.testData")
local testUtils = require("shared.testUtils")

return function()
    local width, height = testData.getPlotDimensions()

    local SLOT_NAME = "lootplot.content.s0:slot"
    local SLOT_NAME_REROLL = "lootplot.content.s0:shop_slot"

    testUtils.addTest("slot_pulse_trigger", function(self)
        local plot = testUtils.prepare(self, true)
        local ppos = lp.PPos({slot = plot:coordsToIndex(math.floor(width / 2), math.floor(height / 2)), plot = plot})

        -- Spawn slot
        if server then lp.trySpawnSlot(ppos, server.entities[SLOT_NAME]) end
        self:tick(20)

        local slot = lp.posToSlot(ppos)
        self:assert(slot, "expected slot, got nil")
        ---@cast slot lootplot.SlotEntity

        if server then lp.forceTriggerEntity("PULSE", slot) end
        self:tick(20)
    end)

    testUtils.addTest("slot_reroll_trigger", function(self)
        local plot = testUtils.prepare(self, true)
        local ppos = lp.PPos({slot = plot:coordsToIndex(math.floor(width / 2), math.floor(height / 2)), plot = plot})

        -- Spawn slot
        if server then lp.trySpawnSlot(ppos, server.entities[SLOT_NAME_REROLL]) end
        self:tick(20)

        local slot = lp.posToSlot(ppos)
        self:assert(slot, "expected slot, got nil")
        ---@cast slot lootplot.SlotEntity

        if server then lp.forceTriggerEntity("REROLL", slot) end
        self:tick(20)
    end)
end
