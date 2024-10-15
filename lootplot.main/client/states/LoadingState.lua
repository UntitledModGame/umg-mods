local runManager = require("shared.run_manager")
local Z_ORDER = require("client.z_order")

local ContinueState = require("client.states.ContinueState")
local NewRunState = require("client.states.NewRunState")

---@class lootplot.main.LoadingState: objects.Class, state.IState
local LoadingState = objects.Class("lootplot.main:LoadingState")




function LoadingState:init()
    self.runInfoChecked = false
end

function LoadingState:onAdded(z)
    -- Dummy, but required to pass IState interface typecheck.
end

function LoadingState:onRemoved()
    -- Dummy, but required to pass IState interface typecheck.
end

function LoadingState:update(dt)
    if runManager.hasReceivedInfo() then
        local runInfo = runManager.getSavedRun()

        state.pop(self)
        if runInfo then
            local continueState = ContinueState(runInfo)
            state.push(continueState, Z_ORDER.CONTINUE_RUN_STATE)
        else
            local newRunState = NewRunState()
            state.push(newRunState, Z_ORDER.NEW_RUN_STATE)
        end
    end
end

function LoadingState:draw()
    -- Dummy, but required to pass IState interface typecheck.
end

return LoadingState
