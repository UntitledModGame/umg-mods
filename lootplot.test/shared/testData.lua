-- Scratch data for test data
local testData = {}

---@type lootplot.test.TestContext?
testData.context = nil ---@private
---@type Entity?
testData.player = nil ---@private
---@type lootplot.test.Screen
testData.screen = nil ---@private

---@private
testData.plotWidth = 11 -- Please don't change
---@private
testData.plotHeight = 11-- Please don't change

local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not testData.context then
        testData.context = ent.lootplotContext
        lp.initialize(testData.context)
    else
        -- TODO: change this to a log, as opposed to a print
        print("WARNING::: Duplicate lootplot.test context created!!")
    end
end)

function testData.getPlotDimensions()
    return testData.plotWidth, testData.plotHeight
end

function testData.getContext()
    return testData.context
end

---@param context lootplot.test.TestContext
function testData.setContext(context)
    testData.context = context
end

function testData.getPlayer()
    return testData.player
end

---@param player Entity
function testData.setPlayer(player)
    testData.player = player
end

function testData.getScreenUI()
    assert(client, "client-side call only")
    return testData.screen
end

---@param screen lootplot.test.Screen
function testData.setScreenUI(screen)
    assert(client, "client-side call only")
    testData.screen = screen
end

return testData
