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


function Pipeline:push(fn, delay, ...)
    self.buffer:add({
        func = fn,
        args = {...},
        delay = delay or 0
    })
end


function Pipeline:step()
    local time = umg.getWorldTime()
    
    if time > self.nextExecuteTime then
        local obj = self.buffer:pop()
        obj.func(unpack(obj.args))
        self.nextExecuteTime = time + obj.delay
    end
end

