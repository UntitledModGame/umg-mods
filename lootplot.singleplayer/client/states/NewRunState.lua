
local runManager = require("shared.run_manager")
local settingManager = require("shared.setting_manager")
local helper = require("client.states.helper")
local Z_ORDER = require("client.z_order")

local LPState = require("client.states.LPState")
local NewRunScene = require("client.scenes.NewRunScene")


---@class lootplot.singleplayer.NewRunState: objects.Class, state.IState
local NewRunState = objects.Class("lootplot.singleplayer:NewRunState")


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

        startNewRun = function(startingItemName, background)
            umg.analytics.collect("lootplot.singleplayer:startNewRun", {
                playerWinCount = lp.getWinCount(),
                chosenStartingItem = startingItemName,
                chosenBackground = background
            })

            state.pop(self)
            state.push(LPState(), Z_ORDER.LOOTPLOT_STATE)
            settingManager.setLastSelectedBackground(background)

            -- BIG TODO AND FIXME
            -- Currently we picked first option for worldgen item.
            -- Perhaps we create worldgen selection screen...?
            return runManager.sendStartRunPacket({
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
    helper.drawBackground()
    self.scene:render(love.window.getSafeArea())
end

return NewRunState

