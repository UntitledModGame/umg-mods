---@meta
scheduling = {}

---@type scheduling.Delay
scheduling.delay = {}

---@generic T
---@param time number Delay time in seconds.
---@param func fun(...:T) Function to execute.
---@param ... T Parameters for the `func`.
---@return scheduling.Delay
function scheduling.delay(time, func, ...)
end

---@param func fun(...:T) Function to execute.
---@param ... T Parameters for the `func`.
function scheduling.nextTick(func, ...)
end

---@generic T: function
---@param skips integer Amount of skips before calling the actual function.
---@param func T Function to execute after `skips` skips.
---@return T
function scheduling.skip(skips, func)
end

return scheduling
