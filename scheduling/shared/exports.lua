---@meta
local scheduling = {}


local delay = require("shared.delay")
local nextTick = require("shared.next_tick")
local skip = require("shared.skip")



---@generic T
---@param time number Delay time in seconds.
---@param func fun(...:T) Function to execute.
---@param ... T Parameters for the `func`.
---@return scheduling.Delay
function scheduling.delay(time, func, ...)
    return delay(time, func, ...)
end

---@generic T
---@param func fun(...:T) Function to execute.
---@param ... T Parameters for the `func`.
function scheduling.nextTick(func, ...)
    return nextTick(func, ...)
end

---@generic T: function
---@param skips integer Amount of skips before calling the actual function.
---@param func T Function to execute after `skips` skips.
---@return T
function scheduling.skip(skips, func)
    return skip(skips, func)
end



if false then
    ---Availability: Client and Server
    _G.scheduling = scheduling
end
umg.expose("scheduling", scheduling)
return scheduling
