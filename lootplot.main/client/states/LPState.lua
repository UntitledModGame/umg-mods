local Scene = require("client.scenes.LPScene")

---@class lootplot.main.State: objects.Class, state.IState
local LPState = objects.Class("lootplot.main:State")


-- This global-state is kinda bad, but we need it 
-- due to the global-nature of base lootplot evbuses
local lpState = nil

local winLose = require("shared.win_lose")
winLose.setEndGameCallback(function(win)
    if lpState then
        lpState:getScene():showEndGameDialog(win)
    end
end)

-- (action button stuff)
---@param selection lootplot.Selected
umg.on("lootplot:selectionChanged", function(selection)
    if lpState then
        local scene = lpState:getScene()
        scene:setSelection(selection)
    end
end)


function LPState:init()
    ---@type lootplot.main.Scene
    assert(not lpState, "Cannot push 2 LPStates!")
    lpState = self
    self.scene = Scene(self)
    self.listener = input.InputListener()
    self.movingWithMouse = false
    self.rightClick = false
    self.lastCamMouse = {0, 0} -- to track threshold
    self.claimedByControl = false

    self.lastHoveredEntity = nil

    self.listener:onAnyPressed(function(this, controlEnum)
        local consumed = self.scene:controlPressed(controlEnum)
        if consumed then
            this:claim(controlEnum)
        end
    end)

    self.listener:onPressed({"input:ESCAPE"}, function(this, controlEnum)
        self.scene:openPauseBox()
        this:claim(controlEnum)
    end)

    self.listener:onPressed({"input:CLICK_PRIMARY", "input:CLICK_SECONDARY"}, function(this, controlEnum)
        local x,y = input.getPointerPosition()
        self.claimedByControl = self.scene:controlClicked(controlEnum,x,y)
        if self.claimedByControl then
            this:claim(controlEnum)
            return
        end

        if controlEnum == "input:CLICK_SECONDARY" then
            -- For camera panning
            self.lastCamMouse[1], self.lastCamMouse[2] = x, y
            self.rightClick = true
            this:claim(controlEnum)
            return
        end
    end)

    self.listener:onReleased("input:CLICK_PRIMARY", function()
        if not self.claimedByControl then
            local run = lp.main.getRun()

            if run then
                local plot = run:getPlot()
                local x, y = input.getPointerPosition()
                local wx, wy = camera.get():toWorldCoords(x, y)
                local ppos = plot:getClosestPPos(wx, wy)

                if not lp.posToSlot(ppos) then
                    lp.deselectItem()
                end
            end
        end

        self.claimedByControl = false
    end)

    self.listener:onReleased("input:CLICK_SECONDARY", function()
        self.movingWithMouse = false
        self.rightClick = false
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

    self.listener:onPointerMoved(function(this, x,y, dx,dy)
        self.scene:pointerMoved(x,y, dx,dy)

        if
            not self.movingWithMouse
            and self.rightClick
            and math.distance(x - self.lastCamMouse[1], y - self.lastCamMouse[2]) > 20
        then
            self.movingWithMouse = true
            dx = x - self.lastCamMouse[1]
            dy = y - self.lastCamMouse[2]
        end

        if self.movingWithMouse then
            local z = follow.getCurrentZoomMultipler()

            for _, ent in ipairs(control.getControlledEntities()) do
                ent.x = ent.x - dx / z
                ent.y = ent.y - dy / z
            end
        end
    end)
end

function LPState:onAdded(zorder)
    input.addListener(clickables.getListener(), zorder)
    input.addListener(control.getListener(), zorder)
    input.addListener(follow.getListener(), zorder)
    input.addListener(hoverables.getListener(), zorder)
    input.addListener(self.listener, zorder + 1)
end

function LPState:onRemoved()
    input.removeListener(clickables.getListener())
    input.removeListener(control.getListener())
    input.removeListener(follow.getListener())
    input.removeListener(hoverables.getListener())
    input.removeListener(self.listener)
    lpState = nil
end

function LPState:update(dt)
    local hovered = lp.getHoveredSlot()
    local hoveredEntity = nil

    if hovered then
        local slotEnt = hovered.entity
        local itemEnt = lp.slotToItem(slotEnt)
        hoveredEntity = itemEnt or slotEnt
    end

    if hoveredEntity ~= self.lastHoveredEntity then
        self:getScene():setCursorDescription(hoveredEntity)
        self.lastHoveredEntity = hoveredEntity
    end

end

function LPState:draw()
    rendering.drawWorld()
    self.scene:render(love.window.getSafeArea())
end


function LPState:getScene()
    return self.scene
end

function LPState:getSpeedMultipler()
    return 2 ^ self.scene.gameSpeedMultiplerFactor
end

return LPState
