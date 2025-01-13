
local runManager = require("shared.run_manager")
local settingManager = require("shared.setting_manager")
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

    local backgrounds = lp.backgrounds.getRegisteredBackgrounds()
    assert(#backgrounds > 0, "no backgrounds?")
    table.sort(backgrounds, function(a, b)
        return a.id < b.id
    end)
    local selected = settingManager.getLastSelectedBackground()

    self.scene = NewRunScene({
        backgrounds = backgrounds,
        lastSelectedBackground = selected,

        -- BIG TODO AND FIXME
        -- Currently we picked first option.
        -- We should create worldgen selection screen for it though.
        startNewRun = function(startingItemName, background)
            umg.analytics.collect("lootplot.main:newRun", {
                starterItem = startingItemName,
                worldgenItem = lp.worldgen.WORLDGEN_ITEMS[1],
                hadRun = not not cancelRun,
                background = background
            })

            state.pop(self)
            state.push(LPState(), Z_ORDER.LOOTPLOT_STATE)
            settingManager.setLastSelectedBackground(background)

            -- TODO: Proper setup options
            return runManager.startRun({
                starterItem = startingItemName,
                worldgenItem = lp.worldgen.WORLDGEN_ITEMS[1],
                seed = "",
                background = background
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
    return self.scene:update(dt)
end

function NewRunState:draw()
    self.scene:render(love.window.getSafeArea())
end

return NewRunState

