


local TestContext = objects.Class()


function TestContext:init(name, func)
    -- The current "tick count" that is synced between the
    -- client and the server.
    self.expectedTick = 0
    self.coro = coroutine.create(func)
    self.name = name
end



function TestContext:fail(err)
    self.failed = true
    self.failReason = err
end



function TestContext:setCurrentTick(tickNumber)

end


function TestContext:update(dt)
    if self.coro
end


local function incrementTick(self)
    if self.expectedTick
end


function TestContext:tick(N)
    --[[
        waits N ticks.
        Useful for syncing server / client
    ]]
    N = N or 1
    for i=1, N do
        incrementTick(self)
        coroutine.yield()
    end
end


function TestContext:assert(bool, err)
    
end


function TestContext:assertEquals(a, b, err)
    if a ~= b then
        self:fail(tostring(a) .. " not equal to: " .. tostring(b) .. " :: " .. err)
    end
end






return TestContext
