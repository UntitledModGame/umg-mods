--[[
    execution pipeline.

    In lootplot, many actions/triggers are "buffered";
    this provides much better UX, since users can actually see what is
    happening on screen; as opposed to everything triggering everything else.
]]

---@class lootplot.Pipeline: objects.Class
local Pipeline = objects.Class("lootplot:Pipeline")


function Pipeline:init()
    self.buffer = objects.Array()

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

---@param dt number
function Pipeline:tick(dt)
    local buf = self.buffer
    self.delay = math.max(self.delay - dt, 0)
    while self.delay <= 0 and buf:size() > 0 do
        local obj = buf:pop()
        pollObj(self, obj)
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

---@cast Pipeline +fun():lootplot.Pipeline
return Pipeline
