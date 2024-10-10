-- ContinueState is responsible of doing this thing:
-- For host: Show continue run dialog
-- For non-host: Show message "Host is preparing run"

local ContinueRunDialog = require("client.scenes.ContinueRunDialog")


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

function ContinueState:onAdded(zorder)
    input.addListener(self.listener, zorder)
end

function ContinueState:onRemoved()
    input.removeListener(self.listener)
end

function ContinueState:update(dt)
    state.pop(self)

    state.push(self.lpState, LP_STATE_Z_ORDER)
    state.pop(self)
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
