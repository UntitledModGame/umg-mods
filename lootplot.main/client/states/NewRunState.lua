
local runManager = require("shared.run_manager")
local helper = require("client.states.helper")
local Z_ORDER = require("client.z_order")

local LPState = require("client.states.LPState")
local NewRunScene = require("client.scenes.NewRunScene")


---@class lootplot.main.NewRunState: objects.Class, state.IState
local NewRunState = objects.Class("lootplot.main:NewRunState")


---@param cancelAction function?
function NewRunState:init(cancelAction)
    local cancelRun = nil

    if cancelAction then
        function cancelRun()
            state.pop(self)
            return cancelAction()
        end
    end

    self.scene = NewRunScene({
        startNewRun = function(startingItemName)
            umg.analytics.collect("lootplot.main:newRun", {
                starterItem = startingItemName,
                hadRun = not not cancelRun
            })

            state.pop(self)
            state.push(LPState(), Z_ORDER.LOOTPLOT_STATE)
            -- TODO: Proper setup options
            return runManager.startRun({
                starterItem = startingItemName,
                seed = "",
            })
        end,
        cancelRun = cancelRun
    })
    self.scene:makeRoot()
    self.listener = helper.createStateListener(self.scene)
end

function NewRunState:onAdded(z)
    input.addListener(self.listener, z)
end

function NewRunState:onRemoved()
    input.removeListener(self.listener)
end

function NewRunState:update(dt)
end

function NewRunState:draw()
    self.scene:render(love.window.getSafeArea())
end

return NewRunState

