-- RunState is responsible of doing this thing:
-- For host: Show continue run dialog
-- For non-host: Show message "Host is preparing run"

local fonts = require("client.fonts")
local ContinueRunDialog = require("client.scenes.ContinueRunDialog")


---@class lootplot.main.RunState: objects.Class, state.IState
local RunState = objects.Class("lootplot.main:RunState")

function RunState:init()
    self.scene = nil
    self.listener = input.InputListener()

    self.listener:onAnyPressed(function(this, controlEnum)
        if self.scene and self.scene:controlPressed(controlEnum) then
            return this:claim(controlEnum)
        end
    end)

    self.listener:onPressed({"input:ESCAPE"}, function(this, controlEnum)
        -- self.scene:openPauseBox()
        this:claim(controlEnum)
    end)

    self.listener:onPressed({"input:CLICK_PRIMARY", "input:CLICK_SECONDARY"}, function(this, controlEnum)
        local x,y = input.getPointerPosition()
        if self.scene and self.scene:controlClicked(controlEnum,x,y) then
            return this:claim(controlEnum)
        end
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

---@param args? {continueRunAction:(fun()),newRunAction:fun(seed:string|nil)}
function RunState:setup(args)
    if args then
        ---@type lootplot.main.ContinueRunDialog
        local crd = ContinueRunDialog(args.continueRunAction, args.newRunAction)
        self.scene = crd
    else
        self.scene = ui.elements.Text({
            text = "Host is preparing run...",
            font = fonts.getLargeFont(),
            color = objects.Color.WHITE,
            outline = 1,
            outlineColor = objects.Color.BLACK
        })
    end

    self.scene:makeRoot()
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
