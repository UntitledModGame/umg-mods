local IState = require("client.IState")

---Availability: **Client**
---@class state
local state = {}
if false then
    _G.state = state
end



---@type table<integer, state.IState>
local zorderByState = {}
---@type table<state.IState, integer>
local inverseZOrderByState = {--[[
    [stateTable] -> zOrder
]]}
---@type state.IState[]
local sortedState = {}

---@param a state.IState
---@param b state.IState
local function sortState(a, b)
    return inverseZOrderByState[a] < inverseZOrderByState[b]
end



local IStateTc = typecheck.interface(IState)
---Typecheck to test if an object adheres to `IState` interface specification.
state.interfaceTypecheck = IStateTc



local statePushTc = typecheck.assert(IStateTc, "number")

---Push new state to the global state.
---@param istate state.IState|table Object that implements `state.IState` interface.
---@param zorder integer Z-order of this state. Must not be occupied.
function state.push(istate, zorder)
    statePushTc(istate, zorder)
    if zorderByState[zorder] then
        umg.melt("z-order "..zorder.." is occupied")
    end

    zorderByState[zorder] = istate
    inverseZOrderByState[istate] = zorder
    table.insert(sortedState, istate)
    table.sort(sortedState, sortState)
    return istate:onAdded(zorder)
end

---Remove state from the global state.
---@param istate state.IState|table Object that implements `state.IState` interface (must be previously added using `state.push`).
function state.pop(istate)
    assert(IStateTc(istate))

    local zorder = inverseZOrderByState[istate]
    assert(zorder, "state is not yet registered (forgot to call `state.push`?)")

    -- Find where it was added in sorted state
    local found = false
    for i, s in ipairs(sortedState) do
        if s == istate then
            table.remove(sortedState, i)
            found = true
            break
        end
    end
    assert(found) -- if this is not found, then it's logic error

    inverseZOrderByState[istate] = nil
    zorderByState[zorder] = nil
    istate:onRemoved()
end



umg.on("@update", function(dt)
    for _, istate in ipairs(sortedState) do
        istate:update(dt)
    end
end)

umg.on("@draw", function()
    for _, istate in ipairs(sortedState) do
        istate:draw()
    end
end)



-- Backward compatibility
state.getGameTime = love.timer.getTime



umg.expose("state", state)
return state
