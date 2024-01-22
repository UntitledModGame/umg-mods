

local TestContext = require("shared.TestContext")


local zenith = {}



local currentTest = nil


local tests = {--[[
    [testName] -> TestContext
]]}


function zenith.test(func)
    local ctx = TestContext(func)
    
end



function zenith.fail(err)
    err = err or "(no error)"
    currentTest.failed = true
end


function zenith.assert(bool, err)
    if not bool then
        zenith.fail(err)
    end
end


function zenith.assertEquals(a, b, err)
    if a ~= b then
        zenith.fail(err .. "  :: not equal: " .. tostring(a) .. ", " .. tostring(b))
    end
end





local testing = false

function zenith.runTests()
    assert(not testing, "runTests can only be called once")
    testing = true
end




local allGroup = umg.group()

function zenith.clear()
    if server then 
        for _, ent in ipairs(allGroup)do
            ent:delete()
        end
    end

    zenith.tick(2)
end





local i = 1

local clientReady = true


local waitTicks = 1
local WAIT_N = 8 -- wait X ticks for client to join.


local function startNextTest(index)
    i = index
    local tst = allTests[i]
    if not tst then return end
    currentTest = tst
    clientReady = false
end



local function tryStartNextTest()
    if not server then
        return
    end
    if clientReady then
        startNextTest(i)
        server.broadcast("zenithNextTest", i)
        i = i + 1
        return true
    end
end


local function isTestDone()
    return coroutine.status(currentTest.co) == "dead"
end


local function finishTest()
    if client then
        client.send("zenithReady")
    end
    printResults()
    currentTest = nil
end



umg.on("@tick", function()
    if not testing then
        return
    end

    if server and waitTicks < WAIT_N then
        -- wait for client to join
        waitTicks = waitTicks + 1
        return
    end

    if not currentTest then
        if server then
            tryStartNextTest()
        end
        return
    end

    local co = currentTest.co
    if isTestDone() then
        -- completed test
        finishTest()
        return
    end

    local res, err = coroutine.resume(co)
    if not res then
        -- either test has completed, or there has been error.
        if err then
            zenith.fail(err)
        end
        finishTest()
    end
end)


if client then
    client.on("zenith:nextTest", function(index)
        startNextTest(index)
    end)
end


if server then
    server.on("zenith:ready", function()
        clientReady = true
    end)
end



umg.expose("zenith", zenith)
_G.zenith = zenith

return zenith
