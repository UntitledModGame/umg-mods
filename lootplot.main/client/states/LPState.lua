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
        string = "",
        timeout = 0 -- if 0 = disappear and set accumulated to 0
    }
    self.multiplierEffect = {
        last = 1,
        timeout = 0, -- if 0 = don't play effects
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
    local l = {}
    l.root = layout.NLay.constraint(layout.NLay, layout.NLay, layout.NLay, layout.NLay, layout.NLay)
        :size(0, 0)
    -- Rest of size and data will be set on :draw()
    l.leftTop = layout.NLay.constraint(l.root, l.root, l.root, nil, l.root)
    l.leftMid = layout.NLay.constraint(l.root, l.leftTop, l.root, nil, l.root)
    l.leftBottom = layout.NLay.constraint(l.root, l.leftMid, l.root, nil, l.root)
    l.rightTop = layout.NLay.constraint(l.root, l.root, l.root, nil, l.root)
    l.rightBottom = layout.NLay.constraint(l.root, l.rightTop, l.root, nil, l.root)
    l.accumulator = layout.NLay.constraint(l.rightTop, l.rightTop, l.rightTop, l.rightTop, l.rightTop)
        :bias(1, nil)
    l.multiplier1 = layout.NLay.constraint(l.rightBottom, l.rightBottom, l.rightBottom, l.rightBottom, l.rightBottom)
        :bias(1, nil) -- if width(mul) > width(accumulator)
    l.multiplier2 = layout.NLay.constraint(l.rightBottom, l.rightBottom, l.accumulator, l.rightBottom, l.accumulator)
    self.layout = l
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

---@param value number
---@param nsig integer
---@return string
local function showNSignificant(value, nsig)
	local zeros = math.floor(math.log10(math.max(math.abs(value), 1)))
	local mulby = 10 ^ math.max(nsig - zeros, 0)
	return tostring(math.floor(value * mulby) / mulby)
end

local ACCUMULATED_POINT_SINGLE_CHAR = 0.01
local ACCUMULATED_POINT_FADE_OUT = 0.3
local ACCUMULATED_EFFECT_START = 0.2
local ACCUMULATED_POINT_TOTAL_TIME = 2

function LPState:pointsChanged(points)
    self.accumulatedPoints.accumulated = self.accumulatedPoints.accumulated + points
    self.accumulatedPoints.timeout = ACCUMULATED_POINT_TOTAL_TIME
    self.accumulatedPoints.string = showNSignificant(self.accumulatedPoints.accumulated, 3)

    if self.accumulatedPoints.accumulated > 0 then
        self.accumulatedPoints.string = "+"..self.accumulatedPoints.string
    end
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
        self.accumulatedPoints.timeout = math.max(self.accumulatedPoints.timeout - dt, 0)
        if self.accumulatedPoints.timeout <= 0 then
            self.accumulatedPoints.accumulated = 0 -- reset
            self.accumulatedPoints.string = "" -- reset
        end
    end

    local run = lp.main.getRun()
    if run then
        self.multiplierEffect.timeout = math.max(self.multiplierEffect.timeout - dt, 0)
        local pointMul = run:getAttribute("POINTS_MULT")

        if self.multiplierEffect.last ~= pointMul then
            self.multiplierEffect.timeout = ACCUMULATED_EFFECT_START
            self.multiplierEffect.last = pointMul
        end
    end
end

local interp = localization.newInterpolator
local ROUND_AND_LEVEL = interp("{wavy amp=0.5 k=0.5}{outline thickness=2}Round %{round}/%{numberOfRounds} - Level %{level}")
local FINAL_ROUND_LEVEL = interp("{wavy freq=2.5 amp=0.75 k=1}{outline thickness=2}{c r=1 g=0.2 b=0.1}FINAL ROUND %{round}/%{numberOfRounds}{/level}{/outline}{/wavy}{wavy amp=0.5 k=0.5}{outline thickness=2} - Level %{level}")
local POINTS_NORMAL = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}Points: %{colorEffect}%{points}/%{requiredPoints}")
local POINTS_GAME_OVER = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}{c r=0.7 g=0.1 b=0}GAME OVER! (%{points}/%{requiredPoints})")
local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline thickness=2}{c r=1 g=0.843 b=0.1}$ %{money}")

---@param constraint {get:fun(self:any):(number,number,number,number)}
---@param txt string
---@param font love.Font
---@param align love.AlignMode
---@param s number
local function printRichTextByConstraint(constraint, txt, font, align, s)
    local x, y, w = constraint:get()
    return text.printRich(txt, font, x, y, w / s, align, 0, s, s)
end

---@param constraint {get:fun(self:any):(number,number,number,number)}
---@param txt string
---@param font love.Font
---@param align love.AlignMode
---@param s number
---@param eff number
local function printRichTextByConstraintWithRotEffect(constraint, txt, font,  align, s, eff)
    local rot = math.sin(eff * 8) * 0.15
    local x, y, w, h = constraint:get()
    local hw, hh = w / 2, h / 2
    return text.printRich(txt, font, x + hw, y + hh, w / s, align, rot, s, s, hw / s, hh / s)
end

---@param x number
local function easeOutQuad(x)
    return 1 - (1 - x) * (1 - x);
end

---@param color number[]
---@param text string
local function surroundColor(color, text)
    return string.format("{c r=%.2f g=%.2f b=%.2f}%s{/c}", color[1], color[2], color[3], text)
end

local function drawRegions(rlist)
    love.graphics.setColor(0,1,1)
    for _, r in pairs(rlist) do
        love.graphics.rectangle("line", r:get())
    end
    love.graphics.setColor(1,1,1)
end

function LPState:drawHUD()
    local run = lp.main.getRun()
    if not run then return end

    local gs = globalScale.get()
    local l = self.layout
    l.root:margin({gs * 16, gs * 16, 0, gs * 48})
    l.leftTop:margin({gs * -8, 0, 0, 0}):size(0, 32 * gs)
    l.leftMid:size(0, 32 * gs)
    l.leftBottom:size(0, 32 * gs)
    l.rightTop:margin({gs * -8, 0, 0, 0}):size(0, 64 * gs)
    l.rightBottom:size(0, 64 * gs)

    local pointMul = self.multiplierEffect.last
    local largerFont = fonts.getSmallFont(64)
    local accWidth = largerFont:getWidth(self.accumulatedPoints.string)
    local mulText = ""
    if pointMul ~= 1 then
        mulText = "(x"..showNSignificant(pointMul, 4)..")"
    end
    local mulWidth = largerFont:getWidth(mulText)
    local mulConstraint
    if accWidth == 0 then
        mulConstraint = l.accumulator
    else
        mulConstraint = mulWidth > accWidth and l.multiplier1 or l.multiplier2
    end
    mulConstraint:size(mulWidth * gs, 0)

    local points = run:getAttribute("POINTS")
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
        pointsText = POINTS_GAME_OVER({
            points = showNSignificant(points, 3),
            requiredPoints = requiredPoints
        })
    else
        pointsText = POINTS_NORMAL({
            colorEffect = colorEffect,
            points = showNSignificant(points, 3),
            requiredPoints = requiredPoints,
        })
    end

    local roundTextMaker = ROUND_AND_LEVEL
    if round >= numberOfRounds and points < requiredPoints then
        roundTextMaker = FINAL_ROUND_LEVEL
    end
    local roundText = roundTextMaker({
        round = round,
        numberOfRounds = numberOfRounds,
        level = run:getAttribute("LEVEL")
    })

    local font = fonts.getSmallFont(32)
    love.graphics.setColor(1, 1, 1)
    printRichTextByConstraint(l.leftTop, roundText, font, "left", gs)
    printRichTextByConstraint(l.leftMid, pointsText, font, "left", gs)
    printRichTextByConstraint(l.leftBottom, MONEY({money = run:getAttribute("MONEY")}), font, "left", gs)

    if self.accumulatedPoints.timeout > 0 then
        local t = ACCUMULATED_POINT_TOTAL_TIME - self.accumulatedPoints.timeout
        local sub = self.accumulatedPoints.string:sub(1, math.floor(t / ACCUMULATED_POINT_SINGLE_CHAR))
        local opacity = easeOutQuad(math.clamp(self.accumulatedPoints.timeout / ACCUMULATED_POINT_FADE_OUT, 0, 1))
        local richText = string.format("{wavy}{outline thickness=%.2f}", opacity * 4)

        local col
        if self.accumulatedPoints.accumulated < 0 then
            col = lp.COLORS.BAD_COLOR
        else
            col = lp.COLORS.POINTS_COLOR
        end

        l.accumulator:size(accWidth * gs, 0)
        love.graphics.setColor(col[1], col[2], col[3], opacity)
        local eff = self.accumulatedPoints.timeout - ACCUMULATED_POINT_TOTAL_TIME + ACCUMULATED_EFFECT_START
        printRichTextByConstraintWithRotEffect(l.accumulator, richText..sub, largerFont, "left", gs, math.max(eff / ACCUMULATED_EFFECT_START, 0))
    end

    local mulTextWithEff = "{wavy}{outline thickness=4}"..mulText.."{/outline}{/wavy}"
    love.graphics.setColor(1, 1, 1)
    printRichTextByConstraintWithRotEffect(mulConstraint, surroundColor(lp.COLORS.POINTS_MULT_COLOR, mulTextWithEff), largerFont, "center", gs, self.multiplierEffect.timeout / ACCUMULATED_EFFECT_START)
    -- drawRegions(l)
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
