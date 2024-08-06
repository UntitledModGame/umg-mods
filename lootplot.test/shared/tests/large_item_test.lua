local testData = require("shared.testData")
local testUtils = require("shared.testUtils")
local LargeItemTest

if server then
    LargeItemTest = require("server.LargeItemTest")
end

return function()
    testUtils.addTest("the_big_item_test", function(self)
        local plot = testUtils.prepare(self, true)

        if server then
            local lit = LargeItemTest(plot)
            testData.setLargeItemTest(lit)
            lit:setup()
        end

        testData.setLITReady()
    end)
end
