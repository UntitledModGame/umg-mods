
local runManager = require("shared.run_manager")

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
end

function NewRunState:onAdded(z)
    -- Dummy, but required to pass IState interface typecheck.
end

function NewRunState:onRemoved()
    -- Dummy, but required to pass IState interface typecheck.
end

function NewRunState:update(dt)
end

function NewRunState:draw()
    self.scene:render(love.window.getSafeArea())
end

return NewRunState

