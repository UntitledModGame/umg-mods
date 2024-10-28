-- ContinueState is responsible of doing showing
-- previous run and letting user starting new run.

local ContinueRunDialog = require("client.scenes.ContinueRunDialog")
local helper = require("client.states.helper")
local runManager = require("shared.run_manager")
local Z_ORDER = require("client.z_order")

local LPState = require("client.states.LPState")
local NewRunState = require("client.states.NewRunState")


---@class lootplot.main.ContinueState: objects.Class, state.IState
local ContinueState = objects.Class("lootplot.main:ContinueState")


---@param runInfo lootplot.main.RunMeta
function ContinueState:init(runInfo)

    self.callbackCalled = false
    ---@type lootplot.main.ContinueRunDialog
    self.scene = ContinueRunDialog({
        runInfo = runInfo,
        continueRun = function()
            state.pop(self)
            state.push(LPState(), Z_ORDER.LOOTPLOT_STATE)
            return runManager.continueRun()
        end,
        startRun = function()
            state.pop(self)

            local function cancel()
                return state.push(ContinueState(runInfo), Z_ORDER.CONTINUE_RUN_STATE)
            end

            return state.push(NewRunState(cancel), Z_ORDER.NEW_RUN_STATE)
        end
    })

    self.scene:makeRoot()
    self.listener = helper.createStateListener(self.scene)
end

function ContinueState:onAdded(zorder)
    input.addListener(self.listener, zorder)
end

function ContinueState:onRemoved()
    input.removeListener(self.listener)
end

function ContinueState:update(dt)
end

function ContinueState:draw()
    if self.scene then
        self.scene:render(love.window.getSafeArea())
    end
end

---@param w number
---@param h number
function ContinueState:resize(w, h)
    self.scene:resize(w, h)
end

return ContinueState
