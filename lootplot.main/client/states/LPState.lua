local Scene = require("client.scenes.LPScene")
local globalScale = require("client.globalScale")
local fonts = require("client.fonts")

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

umg.on("lootplot:pointsChanged", function(_, delta)
    if lpState then
        lpState:pointsChanged(delta)
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

    self.accumulatedPoints = {
        accumulated = 0,
        timeout = 0 -- if 0 = disappear and set accumulated to 0
    }

    -- self.listener:onReleased("input:CLICK_PRIMARY", function()
    --     if not self.claimedByControl then
    --         local run = lp.main.getRun()

    --         if run then
    --             local plot = run:getPlot()
    --             local x, y = input.getPointerPosition()
    --             local wx, wy = camera.get():toWorldCoords(x, y)
    --             local ppos = plot:getClosestPPos(wx, wy)

    --             if not lp.posToSlot(ppos) then
    --                 lp.deselectItem()
    --             end
    --         end
    --     end

    --     self.claimedByControl = false
    -- end)

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
            local z = follow.getScaleFromZoom()

            for _, ent in ipairs(control.getControlledEntities()) do
                ent.x = ent.x - dx / z
                ent.y = ent.y - dy / z
            end
        end
    end)

    -- NLay layouts
    self.layout = {}
    self.layout.root = layout.NLay.constraint(layout.NLay, layout.NLay, layout.NLay, layout.NLay, layout.NLay)
        :size(0, 0)
    self.layout.top = layout.NLay.constraint(self.layout.root, self.layout.root, self.layout.root, nil, self.layout.root)
    self.layout.bottom = layout.NLay.constraint(self.layout.root, self.layout.top, self.layout.root, nil, self.layout.root)
    self.layout.topLeft, self.layout.topRight = layout.NLay.split(self.layout.top, "horizontal", 1, 1)
    self.layout.bottomLeft, self.layout.bottomRight = layout.NLay.split(self.layout.bottom, "horizontal", 2, 1)
end

function LPState:onAdded(zorder)
    input.addListener(chat.getListener(), zorder + 2)
    input.addListener(clickables.getListener(), zorder)
    input.addListener(control.getListener(), zorder)
    input.addListener(follow.getListener(), zorder)
    input.addListener(hoverables.getListener(), zorder)
    input.addListener(lp.getSelectionListener(), zorder)
    input.addListener(self.listener, zorder + 1)
end

function LPState:onRemoved()
    input.removeListener(chat.getListener())
    input.removeListener(clickables.getListener())
    input.removeListener(control.getListener())
    input.removeListener(follow.getListener())
    input.removeListener(hoverables.getListener())
    input.removeListener(self.listener)
    lpState = nil
end

-- Total: 4 seconds
local ACCUMULATED_POINT_FADE_IN = 0.15
local ACCUMULATED_POINT_FADE_OUT = 0.3
local ACCUMULATED_POINT_TOTAL_TIME = 2
assert((ACCUMULATED_POINT_FADE_IN + ACCUMULATED_POINT_FADE_OUT) <= ACCUMULATED_POINT_TOTAL_TIME)

function LPState:pointsChanged(points)
    self.accumulatedPoints.accumulated = self.accumulatedPoints.accumulated + points
    self.accumulatedPoints.timeout = ACCUMULATED_POINT_TOTAL_TIME
end

function LPState:update(dt)
    local hoveredSlot = lp.getHoveredSlot()
    local hoveredEntity = nil

    if hoveredSlot then
        local slotEnt = hoveredSlot.entity
        local itemEnt = lp.slotToItem(slotEnt)
        hoveredEntity = itemEnt or slotEnt
    else
        -- If item is floating
        local hoveredItem = lp.getHoveredItem()

        if hoveredItem then
            hoveredEntity = hoveredItem.entity
        end
    end

    local selected = lp.getCurrentSelection()
    if selected and selected.item and hoveredEntity == selected.item then
        hoveredEntity = nil

        -- But if there's hovered slot, pick that instead
        if hoveredSlot then
            hoveredEntity = hoveredSlot.entity
        end
    end

    if hoveredEntity ~= self.lastHoveredEntity then
        self:getScene():setCursorDescription(hoveredEntity)
        self.lastHoveredEntity = hoveredEntity
    end

    if self.accumulatedPoints.timeout > 0 then
        self.accumulatedPoints.timeout = self.accumulatedPoints.timeout - dt
        if self.accumulatedPoints.timeout <= 0 then
            self.accumulatedPoints.accumulated = 0 -- reset
        end
    end
end

local interp = localization.newInterpolator
local ROUND_NUM = interp("{wavy amp=0.5 k=0.5}{outline thickness=2}Round %{round}/%{numberOfRounds}")
local FINAL_ROUND_NUM = interp("{wavy freq=2.5 amp=0.75 k=1}{c r=1 g=0.2 b=0.1}{outline thickness=2}FINAL ROUND %{round}/%{numberOfRounds}")
local POINTS_NORMAL = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}Points: %{colorEffect}%{points}/%{requiredPoints}")
local POINTS_WITH_MUL = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}Points: %{colorEffect}%{points}/%{requiredPoints}{/c} %{mulColorEffect}(x%{mul})")
local GAME_OVER = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}{c r=0.7 g=0.1 b=0}GAME OVER! (%{points}/%{requiredPoints})")
local LEVEL_NUM = interp("{wavy amp=0.5 k=0.5}{outline thickness=2}Level %{level}")
local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline thickness=2}{c r=1 g=0.843 b=0.1}$ %{money}")

---@param value number
---@param nsig integer
---@return string
local function showNSignificant(value, nsig)
	local zeros = math.floor(math.log10(math.max(math.abs(value), 1)))
	local mulby = 10 ^ math.max(nsig - zeros, 0)
	return tostring(math.floor(value * mulby) / mulby)
end

---@param constraint {get:fun(self:any):(number,number,number,number)}
---@param txt string
---@param font love.Font
---@param align love.AlignMode
---@param s number
local function printRichTextByConstraint(constraint, txt, font, align, s)
    local x, y, w = constraint:get()
    return text.printRich(txt, font, x, y, w / s, align, 0, s, s)
end

---@param x number
local function easeOutQuad(x)
    return 1 - (1 - x) * (1 - x);
end

---@param x number
local function easeOutCubic(x)
    return 1 - x ^ 3
end

function LPState:drawHUD()
    local run = lp.main.getRun()
    if not run then return end

    local gs = globalScale.get()
    self.layout.root:margin(gs * 16)
    self.layout.top:margin({gs * -8, 0, 0, 0}):size(0, 32 * gs)
    self.layout.bottom:size(0, 32 * gs)

    local points = run:getAttribute("POINTS")
    local pointMul = run:getAttribute("POINTS_MULT")
    local requiredPoints = run:getAttribute("REQUIRED_POINTS")
    local round = run:getAttribute("ROUND")
    local numberOfRounds = run:getAttribute("NUMBER_OF_ROUNDS")

    local colorEffect
    if points >= requiredPoints then
        colorEffect = "{c r=0.1 g=1 b=0.2}"
    elseif points < 0 then
        colorEffect = "{c r=1 g=0.2 b=0.1}"
    else
        colorEffect = "{c r=1 g=1 b=1}"
    end

    local pointsText
    if (numberOfRounds < round) and (points < requiredPoints) then
        pointsText = GAME_OVER({
            points = showNSignificant(points, 3),
            requiredPoints = requiredPoints
        })
    elseif pointMul ~= 1 then
        pointsText = POINTS_WITH_MUL({
            colorEffect = colorEffect,
            points = showNSignificant(points, 3),
            requiredPoints = requiredPoints,
            mulColorEffect = string.format(
                "{c r=%.2f g=%.2f b=%.2f}",
                objects.Color.HSVtoRGB(math.log(pointMul, 2) / 10, 0.6, 1)
            ),
            mul = pointMul
        })
    else
        pointsText = POINTS_NORMAL({
            colorEffect = colorEffect,
            points = showNSignificant(points, 3),
            requiredPoints = requiredPoints,
        })
    end

    local roundTextMaker = ROUND_NUM
    if round >= numberOfRounds and points < requiredPoints then
        roundTextMaker = FINAL_ROUND_NUM
    end
    local roundText = roundTextMaker({
        round = round,
        numberOfRounds = numberOfRounds
    })

    local font = fonts.getSmallFont(32)
    love.graphics.setColor(1, 1, 1)
    printRichTextByConstraint(self.layout.topLeft, roundText, font, "left", gs)
    printRichTextByConstraint(self.layout.bottomLeft, pointsText, font, "left", gs)
    printRichTextByConstraint(self.layout.topRight, LEVEL_NUM({level = run:getAttribute("LEVEL")}), font, "right", gs)
    printRichTextByConstraint(self.layout.bottomRight, MONEY({money = run:getAttribute("MONEY")}), font, "right", gs)

    if self.accumulatedPoints.timeout > 0 then
        local x, y, w = self.layout.bottomLeft:get()
        local acX = x + (font:getWidth(text.stripEffects(pointsText)) + 8) * gs
        local opacity = 1
        local t = ACCUMULATED_POINT_TOTAL_TIME - self.accumulatedPoints.timeout

        if t <= ACCUMULATED_POINT_FADE_IN then
            local p = easeOutQuad(t / ACCUMULATED_POINT_FADE_IN)
            acX = acX - 10 * (1 - p)
            opacity = p
        elseif self.accumulatedPoints.timeout <= ACCUMULATED_POINT_FADE_OUT then
            local p = easeOutCubic(math.max(self.accumulatedPoints.timeout / ACCUMULATED_POINT_FADE_OUT, 0))
            acX = acX + 10 * p
            opacity = 1 - p
        end

        local accStr, col
        if self.accumulatedPoints.accumulated < 0 then
            accStr = tostring(self.accumulatedPoints.accumulated)
            col = lp.COLORS.BAD_COLOR
        else
            accStr = "+"..math.abs(self.accumulatedPoints.accumulated)
            col = lp.COLORS.POINTS_COLOR
        end

        local richText = string.format("{wavy}{outline thickness=%.2f}%s", opacity * 2, accStr)
        love.graphics.setColor(col[1], col[2], col[3], opacity)
        text.printRich(richText, font, acX, y, w, "left", 0, gs, gs)
    end
end

function LPState:draw()
    local x, y, w, h = love.window.getSafeArea()

    rendering.drawWorld()
    self.scene:render(x, y, w, h)
    self:drawHUD()
    chat.getChatBoxElement():render(x, y, w, h)
end


function LPState:getScene()
    return self.scene
end

function LPState:getSpeedMultipler()
    return 2 ^ self.scene.gameSpeedMultiplerFactor
end

return LPState
