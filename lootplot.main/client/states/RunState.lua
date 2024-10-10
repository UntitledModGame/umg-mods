-- RunState is responsible of doing this thing:
-- For host: Show continue run dialog
-- For non-host: Show message "Host is preparing run"

local fonts = require("client.fonts")
local ContinueRunDialog = require("client.scenes.ContinueRunDialog")


---@class lootplot.main.RunState: objects.Class, state.IState
local RunState = objects.Class("lootplot.main:RunState")

local KEYS = {
    runInfo = true,
    callback = true
}

---@param args {runInfo:lootplot.main.RunMeta,callback:fun(continue:boolean)}
function RunState:init(args)
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
    self.listener = input.InputListener()

    self.listener:onAnyPressed(function(this, controlEnum)
        self.scene:controlPressed(controlEnum)
        return this:claim(controlEnum) -- Don't propagate
    end)

    self.listener:onPressed({"input:ESCAPE"}, function(this, controlEnum)
        -- TODO: Should we show pause box here?
        this:claim(controlEnum)
    end)

    self.listener:onPressed({"input:CLICK_PRIMARY", "input:CLICK_SECONDARY"}, function(this, controlEnum)
        local x,y = input.getPointerPosition()
        self.scene:controlClicked(controlEnum,x,y)
        return this:claim(controlEnum) -- Don't propagate
    end)

    self.listener:onAnyReleased(function(_, controlEnum)
        if self.scene then
            self.scene:controlReleased(controlEnum)
        end
    end)

    self.listener:onTextInput(function(this, txt)
        if self.scene then
            local captured = self.scene:textInput(txt)
            if captured then
                this:lockTextInput()
            end
        end
    end)

    self.listener:onPointerMoved(function(this, x,y, dx,dy)
        return self.scene:pointerMoved(x,y, dx,dy)
    end)
end

function RunState:onAdded(zorder)
    input.addListener(self.listener, zorder)
end

function RunState:onRemoved()
    input.removeListener(self.listener)
end

function RunState:update(dt)
end

function RunState:draw()
    if self.scene then
        self.scene:render(love.window.getSafeArea())
    end
end

---@param w number
---@param h number
function RunState:resize(w, h)
    self.scene:resize(w, h)
end

return RunState
