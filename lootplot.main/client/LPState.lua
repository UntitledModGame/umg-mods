local Scene = require("client.Scene")

---@class lootplot.main.State: objects.Class, state.IState
local LPState = objects.Class("lootplot.main:State")

function LPState:init()
    ---@type lootplot.main.Scene
    self.scene = Scene()
    self.listener = input.InputListener()

    self.listener:onAnyPressed(function(this, controlEnum)
        local consumed = self.scene:controlPressed(controlEnum)
        if consumed then
            this:claim(controlEnum)
        end
    end)

    self.listener:onPressed({"input:CLICK_PRIMARY", "input:CLICK_SECONDARY"}, function(this, controlEnum)
        local x,y = input.getPointerPosition()
        local consumed = self.scene:controlClicked(controlEnum,x,y)
        if consumed then
            this:claim(controlEnum)
        end
    end)

    self.listener:onAnyReleased(function(_, controlEnum)
        self.scene:controlReleased(controlEnum)
    end)

    self.listener:onTextInput(function(this, txt)
        local captured = self.scene:textInput(txt)
        if captured then
            this:lockTextInput()
        end
    end)

    self.listener:onPointerMoved(function(_, x,y, dx,dy)
        self.scene:pointerMoved(x,y, dx,dy)
    end)
end

function LPState:onAdded(zorder)
    return input.add(self.listener, zorder)
end

function LPState:onRemoved()
    return input.remove(self.listener)
end

function LPState:update(dt)
    
end

function LPState:draw()
    rendering.drawWorld()
    self.scene:render(love.window.getSafeArea())
end

---@param w number
---@param h number
function LPState:resize(w, h)
    self.scene:resize(w, h)
end

function LPState:getScene()
    return self.scene
end

return LPState
