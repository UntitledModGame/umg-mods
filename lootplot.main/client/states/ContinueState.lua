-- ContinueState is responsible of doing this thing:
-- For host: Show continue run dialog
-- For non-host: Show message "Host is preparing run"

local ContinueRunDialog = require("client.scenes.ContinueRunDialog")
local helper = require("client.states.helper")


---@class lootplot.main.ContinueState: objects.Class, state.IState
local ContinueState = objects.Class("lootplot.main:ContinueState")

local KEYS = {
    runInfo = true,
    callback = true
}

---@param args {runInfo:lootplot.main.RunMeta,callback:fun(continue:boolean)}
function ContinueState:init(args)
    assert(args)
    typecheck.assertKeys(args, KEYS)

    self.callbackCalled = false
    ---@type lootplot.main.ContinueRunDialog
    self.scene = ContinueRunDialog(args.runInfo, function(continue)
        if not self.callbackCalled then
            args.callback(continue)
            self.callbackCalled = true
        end
    end)

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
