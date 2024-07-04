

---@param a scheduling.Delay
---@param b scheduling.Delay
local timers = objects.Heap(function(a, b)
    return a:_exectime() < b:_exectime()
end)

local curTime = 0

---@class scheduling.Delay: objects.Class
local Delay = objects.Class("scheduling:Delay")

---@generic T
---@param time number
---@param func fun(...:T)
---@param ... T
function Delay:init(time, func, ...)
    ---@private
    self.func = func
    ---@private
    self.args = {...}
    ---@private
    self.issueTime = curTime
    ---@private
    self.delay = time
    ---@private
    self.cancelled = false
    ---@private
    self.ran = false
    timers:insert(self)
end

---@return boolean @If delay has been cancelled successfully (and not previously cancelled)
function Delay:cancel()
    if not self.cancelled then
        self.cancelled = true
        return true
    end

    return false
end

---@return boolean @If delay has been executed
function Delay:hasExecuted()
    return self.ran
end

---@return number @Time remaining before the delay is executed, or 0 if it already is.
function Delay:timeUntilExecution()
    return math.max(self.issueTime + self.delay - curTime, 0)
end

---@return boolean @Is timer cancelled?
function Delay:isCancelled()
    return self.cancelled
end

---@return number
---@package
function Delay:_exectime()
    return self.issueTime + self.delay
end

---@package
function Delay:_run()
    self.func(unpack(self.args))
end

-- TODO: Should this be using state:gameUpdate???
---@param dt number
umg.on("@update", function(dt)
    curTime = curTime + dt

    while true do
        local delay = timers:peek()
        ---@cast delay scheduling.Delay?

        if not delay then
            break
        end

        if delay:isCancelled() then
            -- Simply pop this delay, but don't execute it.
            timers:pop()
        elseif curTime >= delay:_exectime() then
            -- Execute this delay
            timers:pop()
            delay:_run()
        else
            -- Assume heap is sorted, there should be no delay next to it that
            -- has execution time lower than the first.
            break
        end
    end
end)

return Delay
