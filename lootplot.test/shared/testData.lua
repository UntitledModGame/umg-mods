-- Scratch data for test data
local testData = {}

---@type lootplot.test.TestContext?
testData.context = nil ---@private
---@type Entity?
testData.player = nil ---@private
---@type lootplot.test.Screen?
testData.screen = nil ---@private
---@type lootplot.test.LargeItemTest?
testData.largeItemTest = nil ---@private
testData.litReady = false ---@private

---@private
testData.plotWidth = 15 -- Please don't change
---@private
testData.plotHeight = 15-- Please don't change

local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not testData.context then
        testData.context = ent.lootplotContext
        lp.initialize(testData.context)
    else
        umg.log.error("WARNING::: Duplicate lootplot.test context created!!")
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

function testData.getLargeItemTest()
    return testData.largeItemTest
end

---@param lit lootplot.test.LargeItemTest
function testData.setLargeItemTest(lit)
    testData.largeItemTest = lit
end

function testData.setLITReady()
    testData.litReady = true
end

function testData.isLITReady()
    return testData.litReady
end

umg.definePacket("lootplot.test:updateLITStatus", {typelist = {"boolean"}})

if client then

function testData.triggerLIT()
    client.send("lootplot.test:updateLITStatus", true)
end

client.on("lootplot.test:updateLITStatus", function(litStatus)
    testData.litReady = not not litStatus
end)

elseif server then

server.on("lootplot.test:updateLITStatus", function(activate)
    if activate and testData.litReady and testData.largeItemTest then
        testData.largeItemTest:activateItems()
        testData.litReady = false
        server.broadcast("lootplot.test:updateLITStatus", false)
    end
end)

umg.on("@tick", function()
    if not testData.litReady and testData.largeItemTest and testData.largeItemTest:canActivateItem() then
        testData.litReady = true
        server.broadcast("lootplot.test:updateLITStatus", true)
    end
end)

end

return testData
