local testUtils = require("shared.testUtils")

return function()
    testUtils.addTest("no_slot_check", function(self)
        local plot = testUtils.prepare(self, true)

        plot:foreach(function(ppos)
            local slot = lp.posToSlot(ppos)
            self:assert(slot == nil, "expected no slot, got "..tostring(slot))
        end)

        self:tick(10)
    end)

    local SLOT_NAME = "lootplot.s0.content:slot"
    testUtils.addTest("slot_spawn", function(self)
        local plot = testUtils.prepare(self, false)

        plot:foreach(function(ppos)
            if server then
                lp.trySpawnSlot(ppos, server.entities[SLOT_NAME])
            end
        end)

        self:tick(10)
    end)

    testUtils.addTest("slot_verify", function(self)
        local plot = testUtils.prepare(self, false)

        plot:foreach(function(ppos)
            local slot = lp.posToSlot(ppos)
            self:assert(slot, "expected slot, got nil")

            if slot then
                local id = slot:type()
                self:assert(id == SLOT_NAME, "expected "..SLOT_NAME..", got "..id)
            end
        end)

        self:tick(10)
    end)

    local SLOT_NAME_2 = "lootplot.s0.content:golden_slot"
    for _, v in ipairs({{"try", lp.trySpawnSlot, SLOT_NAME}, {"force", lp.forceSpawnSlot, SLOT_NAME_2}}) do
        testUtils.addTest("slot_"..v[1].."_overwrite", function(self)
            local plot = testUtils.prepare(self, false)

            plot:foreach(function(ppos)
                local slot = lp.posToSlot(ppos)
                self:assert(slot, "expected slot, got nil")

                if server then
                    v[2](ppos, server.entities[SLOT_NAME_2])
                end
            end)

            self:tick(10)

            plot:foreach(function(ppos)
                local slot = lp.posToSlot(ppos)
                self:assert(slot, "expected slot, got nil")

                if slot then
                    local id = slot:type()
                    self:assert(id == v[3], "expected "..v[3]..", got "..id)
                end
            end)

            self:tick(10)
        end)
    end

    testUtils.addTest("slot_remove", function(self)
        local plot = testUtils.prepare(self, false)

        plot:foreach(function(ppos)
            local slot = lp.posToSlot(ppos)
            self:assert(slot, "expected slot, got nil")

            if server and slot then
                lp.destroy(slot)
            end
        end)

        self:tick(10)

        plot:foreach(function(ppos)
            local slot = lp.posToSlot(ppos)
            self:assert(slot == nil, "expected no slot again, got "..tostring(slot))
            self:tick()
        end)
    end)
end
