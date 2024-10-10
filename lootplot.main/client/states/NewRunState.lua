
local runManager = require("shared.run_manager")
local helper = require("client.states.helper")

local NewRunScene = require("client.scenes.NewRunScene")


---@class lootplot.main.NewRunState: objects.Class, state.IState
local NewRunState = objects.Class("lootplot.main:NewRunState")


function NewRunState:init()
    self.scene = NewRunScene({
        startNewRun = function(startingItemName)
            runManager.startRun()
        end
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

