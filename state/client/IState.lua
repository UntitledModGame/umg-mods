---@class state.IState
local IState = {}

---Called when this state is added to global `state` mod.
---@param zorder integer Z-order integer value.
function IState:onAdded(zorder)
end

---Called when this state is removed to global `state` mod.
function IState:onRemoved()
end

---Called every frame.
---@param dt number time elapsed since last frame, in seconds.
function IState:update(dt)
end

---Called every frame.
function IState:draw()
end

return IState
