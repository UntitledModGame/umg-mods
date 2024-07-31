local TestContext = require("shared.TestContext")


local zenith = {}
---@type zenith.TestContext[]
local allTests = {}
local definedTestNames = objects.Set()

---@param name string
---@param func fun(self:zenith.TestContext)
function zenith.test(name, func)
    if definedTestNames:has(name) then
        umg.melt("conflicting test name: "..name, 2)
    end

    allTests[#allTests+1] = TestContext(name, func)
    definedTestNames:add(name)
end

local testing = false
local clientReady = false -- for server
local serverReady = false -- for client
local allGroup = umg.group()
local currentTestIndex = 1

function zenith.runTests()
    assert(not testing, "runTests can only be called once")
    testing = true

    if client then
        client.send("zenith:nextTest")
    end
end

umg.on("@load", zenith.runTests)

---@param test zenith.TestContext
function zenith.clear(test)
    if server then
        for _, ent in ipairs(allGroup)do
            ent:delete()
        end
    end

    test:tick(2)
end


---@param test zenith.TestContext?
local function printResults(test)
    if test then
        local f = #test.fails > 0 and umg.log.error or umg.log.info
        f(string.format("Test %q: %d/%d tests passed.", test.name, test.assertions - #test.fails, test.assertions))
    else
        local total = 0
        local fails = 0
        for _, tst in ipairs(allTests) do
            total = total + tst.assertions
            fails = fails + #tst.fails
        end

        local f = fails > 0 and umg.log.error or umg.log.info
        f(string.format("ALL TESTS: %d/%d tests passed.", total - fails, total))
    end
end

local finishTest
local hasPrintResult = false

local function commonFinishTest(currentTest)
    if not hasPrintResult then
        printResults(currentTest)
        hasPrintResult = true
    end
    return finishTest(currentTest)
end

local function performTestCommon()
    local currentTest = allTests[currentTestIndex]
    if currentTest then
        -- print("Testing", clientReady, serverReady)
        if currentTest:isFinished() then
            return commonFinishTest(currentTest)
        end

        local res, err = currentTest:step()
        if not res then
            -- Test failed unexpectedly
            currentTest:assert(false, err or "(no error)")
            umg.log.fatal(string.format("Test %q failed unexpectedly", currentTest.name))
            return commonFinishTest(currentTest)
        else
            hasPrintResult = false
        end
    end
end

if client then
    function finishTest(test)
        client.send("zenith:nextTest")
        serverReady = false
        currentTestIndex = currentTestIndex + 1
    end

    umg.on("@tick", function()
        if not testing then
            return
        end

        if serverReady then
            return performTestCommon()
        end
    end)
else
    local hasInformedClient = false

    function finishTest(test)
        hasInformedClient = false
        clientReady = false
        currentTestIndex = currentTestIndex + 1
    end

    umg.on("@tick", function()
        if not testing then
            return
        end

        if clientReady then
            if not hasInformedClient then
                server.broadcast("zenith:nextTest")
                hasInformedClient = true
            end

            return performTestCommon()
        end
    end)
end

-- For syncing tests
umg.definePacket("zenith:nextTest", {typelist = {}})

if client then
    client.on("zenith:nextTest", function()
        serverReady = true
    end)
end

if server then
    server.on("zenith:nextTest", function()
        clientReady = true
    end)
end

umg.expose("zenith", zenith)
_G.zenith = zenith

return zenith
