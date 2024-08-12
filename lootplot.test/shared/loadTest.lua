local testUtils = require("shared.testUtils")

umg.on("@load", -100, function()
    -- require("shared.tests.slot_sanity_check")()
    -- require("shared.tests.slot_trigger")()
    require("shared.tests.large_item_test")()
    testUtils.addTest("done", function() end) -- just to set the test name
end)
