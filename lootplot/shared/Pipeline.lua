--[[
    execution pipeline.

    In lootplot, many actions/triggers are "buffered";
    this provides much better UX, since users can actually see what is
    happening on screen; as opposed to everything triggering everything else.
]]

---@class lootplot.Pipeline: objects.Class
local Pipeline = objects.Class("lootplot:Pipeline")


---@param plot lootplot.Plot
function Pipeline:init(plot)
    self.buffer = objects.Array()

    self.plot = plot

    -- the time that we are allowed to execute the next obj in the pipeline.
    -- (used for delaying)
    self.delay = 0
end


function Pipeline:push(fn, ...)
    self.buffer:add({
        func = fn,
        args = {...},
    })
end

---@param delay number
function Pipeline:wait(delay)
    self.buffer:add({
        delay = delay
    })
end

---@param self lootplot.Pipeline
local function pollObj(self, obj)
    if obj.func then
        obj.func(unpack(obj.args))
    end

    if obj.delay then
        self.delay = math.max(self.delay + obj.delay, 0)
    end
end



---@param self lootplot.Pipeline
---@param dt number
local function tickOld(self, dt)
    local buf = self.buffer
    self.delay = math.max(self.delay - dt, 0)
    while self.delay <= 0 and buf:size() > 0 do
        local obj = buf:pop()
        pollObj(self, obj)
    end
end



--[[
NEW PIPELINE :tick(dt) THAT RUNS FASTER:
(needs a bit of fixes, maybe uncomment this at some point...?)
]]
---@param self lootplot.Pipeline
---@param dt number
local function tickFast(self, dt)
    local buf = self.buffer
    while self.delay <= dt and buf:size() > 0 do
        local obj = buf:pop()
        pollObj(self, obj)
    end
    self.delay = math.max(self.delay - dt, 0)
end




local FAST_REQUIREMENT = 10
-- after 15 seconds of runtime, it goes into "fast mode"


---- OLD PIPELINE :tick(dt) FUNCTION:
---- works super well. Tried and tested... its just too slow.
---@param dt number
function Pipeline:tick(dt)
    if self.plot:getPipelineRunningTime() < FAST_REQUIREMENT then
        tickOld(self, dt)
    else
        tickFast(self, dt)
    end
end





function Pipeline:clear()
    self.buffer:clear()
    self.delay = 0
end



---@return boolean
function Pipeline:isEmpty()
    return self.buffer:size() == 0
end

---@cast Pipeline +fun(plot:lootplot.Plot):lootplot.Pipeline
return Pipeline
