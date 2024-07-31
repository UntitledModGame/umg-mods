---@class zenith.TestContext: objects.Class
local TestContext = objects.Class("zenith:TestContext")

---@param name string
---@param func fun(state:zenith.TestContext)
function TestContext:init(name, func)
    -- The current "tick count" that is synced between the
    -- client and the server.
    self.expectedTick = 0
    self.coro = coroutine.create(func)
    self.name = name
    self.fails = {}
    self.assertions = 0
end

if false then
    ---@param name string
    ---@param func fun(state:zenith.TestContext)
    ---@return zenith.TestContext
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function TestContext(name, func) end
end

---@param err string
function TestContext:fail(err)
    umg.log.error(string.format("Test #%d on %q: %s", self.assertions, self.name, self:traceback(err)))
    self.fails[#self.fails+1] = err
end

---waits N ticks.
---Useful for syncing server / client
---@param N integer?
function TestContext:tick(N)
    N = N or 1
    for _=1, N do
        coroutine.yield()
    end
end

---@param bool any
---@param err string?
function TestContext:assert(bool, err)
    self.assertions = self.assertions + 1
    if not bool then
        self:fail(err or "assertion failed")
    end
end

function TestContext:assertEquals(a, b, err)
    self.assertions = self.assertions + 1
    if a ~= b then
        self:fail(tostring(a) .. " not equal to: " .. tostring(b) .. " :: " .. err)
    end
end

function TestContext:isFinished()
    return coroutine.status(self.coro) == "dead"
end

function TestContext:step()
    return coroutine.resume(self.coro, self)
end

function TestContext:traceback(msg)
    return debug.traceback(self.coro, msg)
end

return TestContext
