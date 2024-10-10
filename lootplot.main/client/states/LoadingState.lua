local runManager = require("shared.run_manager")
local RunState = require("client.states.RunState")

---@class lootplot.main.LoadingState: objects.Class, state.IState
local LoadingState = objects.Class("lootplot.main:LoadingState")


local LP_STATE_Z_ORDER = 10
local CONTINUE_RUN_STATE_Z_ORDER = 20

---@param lpState lootplot.main.State
function LoadingState:init(lpState)
    self.lpState = lpState
    self.runState = nil
    self.runInfoChecked = false
end

function LoadingState:onAdded(z)
    -- Dummy, but required to pass IState interface typecheck.
end

function LoadingState:onRemoved()
    -- Dummy, but required to pass IState interface typecheck.
end

function LoadingState:update(dt)
    if lp.main.isReady() then
        if self.runState then
            state.pop(self.runState)
        end

        state.push(self.lpState, LP_STATE_Z_ORDER)
        state.pop(self)
    elseif runManager.hasReceivedInfo() and not self.runInfoChecked then
        self.runInfoChecked = true
        local runInfo = runManager.getSavedRun()

        if runInfo then
            self.runState = RunState({
                runInfo = runInfo,
                callback = runManager.startRun
            })
            state.push(self.runState, CONTINUE_RUN_STATE_Z_ORDER)
        else
            runManager.startRun(false)
        end
    end
end

function LoadingState:draw()
    -- Dummy, but required to pass IState interface typecheck.
end

return LoadingState
