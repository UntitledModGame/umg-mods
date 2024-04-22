--[[
    execution pipeline.

    In lootplot, many actions/triggers are "buffered";
    this provides much better UX, since users can actually see what is
    happening on screen; as opposed to everything triggering everything else.
]]

local Pipeline = objects.Class("lootplot:Pipeline")


function Pipeline:init()
    self.buffer = objects.Array()

    -- the time that we are allowed to execute the next obj in the pipeline.
    -- (used for delaying)
    self.nextExecuteTime = umg.getWorldTime()
end


function Pipeline:push(fn, ...)
    self.buffer:add({
        func = fn,
        args = {...},
    })
end


function Pipeline:wait(delay)
    self.buffer:add({
        delay = delay
    })
end


local function pollObj(self, obj)
    if obj.func then
        obj.func(unpack(obj.args))
    end
    local time = love.timer.getTime()
    if obj.delay then
        self.nextExecuteTime = time + obj.delay
    end
end

function Pipeline:tick()
    local time = umg.getWorldTime()
    
    local buf = self.buffer
    while (time > self.nextExecuteTime) and (buf:size() > 0) do
        local obj = buf:pop()
        pollObj(self, obj)
    end
end


function Pipeline:isEmpty()
    return self.buffer:size() == 0
end


return Pipeline
