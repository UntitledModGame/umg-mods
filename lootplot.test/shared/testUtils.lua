local testData = require("shared.testData")

local testUtils = {}

---@param name string
---@param testfunc fun(context:zenith.TestContext)
function testUtils.addTest(name, testfunc)
    zenith.test("lootplot.test:"..name, function(self)
        if client then
            testData.getScreenUI():setTestName(name)
        end

        return testfunc(self)
    end)
end

---@param ppos lootplot.PPos
local function pposCleaner(ppos)
    local item = lp.posToItem(ppos)
    if item then
        lp.destroy(item)
    end

    local slot = lp.posToSlot(ppos)
    if slot then
        lp.destroy(slot)
    end
end

function testUtils.resetCameraPosition()
    if client then
        follow.initiateZoom(-6)
    end
end

-- Note: does NOT tick. Tick manually.
function testUtils.clearPlot()
    if server then
        local ctx = testData.getContext()
        local plot = ctx:getPlot()
        plot:foreach(pposCleaner)
    end
end

---@param self zenith.TestContext
---@param clearplot boolean
function testUtils.prepare(self, clearplot)
    local plot = testData.getContext():getPlot()
    testUtils.resetCameraPosition()
    if clearplot then
        testUtils.clearPlot()
    end
    self:tick(10)
    return plot
end

return testUtils
