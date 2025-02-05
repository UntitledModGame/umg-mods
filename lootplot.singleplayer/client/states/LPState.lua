local Scene = require("client.scenes.LPScene")
local globalScale = require("client.globalScale")
local fonts = require("client.fonts")

---@class lootplot.singleplayer.State: objects.Class, state.IState
local LPState = objects.Class("lootplot.singleplayer:State")


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
    ---@type lootplot.singleplayer.Scene
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
        timeout = 0
    }

    self.multiplierEffect = {
        last = 1,
        timeout = 0, -- if 0 = don't play effects
    }
    self.bonusEffect = {
        last = 0,
        timeout = 0, -- if 0 = don't play effects
    }

    -- self.listener:onReleased("input:CLICK_PRIMARY", function()
    --     if not self.claimedByControl then
    --         local run = lp.singleplayer.getRun()

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

local ACCUMULATED_POINT_FADE_OUT = 0.3
local ACCUMULATED_POINT_TOTAL_TIME = 2

local ACCUMULATED_JOLT_DURATION = 0.2 -- in seconds

local ACCUMULATED_JOLT_ROTATION_AMOUNT = math.rad(20)
local ACCUMULATED_JOLT_SCALE_BULGE_AMOUNT = 1.2


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
        self.accumulatedPoints.timeout = math.max(self.accumulatedPoints.timeout - dt, 0)
        if self.accumulatedPoints.timeout <= 0 then
            self.accumulatedPoints.accumulated = 0 -- reset
        end
    end

    local run = lp.singleplayer.getRun()
    if run then
        local mulEffect = self.multiplierEffect
        mulEffect.timeout = math.max(mulEffect.timeout - dt, 0)
        local pointMul = run:getAttribute("POINTS_MULT")
        if mulEffect.last ~= pointMul then
            mulEffect.timeout = ACCUMULATED_JOLT_DURATION
            mulEffect.last = pointMul
        end

        local bEffect = self.bonusEffect
        bEffect.timeout = math.max(bEffect.timeout - dt, 0)
        local pointBonus = run:getAttribute("POINTS_BONUS")
        if bEffect.last ~= pointBonus then
            bEffect.timeout = ACCUMULATED_JOLT_DURATION
            bEffect.last = pointBonus
        end
    end
end

local interp = localization.newInterpolator

local ROUND_AND_LEVEL = interp("{wavy amp=0.5 k=0.5}{outline thickness=2}Round %{round}/%{numberOfRounds} - Level %{level}")
local FINAL_ROUND_LEVEL = interp("{wavy freq=2.5 amp=0.75 k=1}{outline thickness=2}{c r=1 g=0.2 b=0.1}FINAL ROUND %{round}/%{numberOfRounds}{/outline}{/wavy}{wavy amp=0.5 k=0.5}{outline thickness=2} - Level %{level}")
local LEVEL_COMPLETE = interp("{c r=0.2 g=1 b=0.4}{wavy amp=0.5 k=0.5}{outline thickness=2}Level %{level} Complete!")
local GAME_OVER = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}{c r=0.7 g=0.1 b=0}GAME OVER! (Round %{round}/%{numberOfRounds})")

local POINTS_NORMAL = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}Points: %{colorEffect}%{points}/%{requiredPoints}")
local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline thickness=2}{c r=1 g=0.843 b=0.1}$ %{money}")

---@param constraint {get:fun(self:any):(number,number,number,number)}
---@param txt string
---@param font love.Font
---@param align love.AlignMode
---@param s number
local function printRichTextByConstraint(constraint, txt, font, align, s, rot)
    local x, y, w, h = constraint:get()
    local hw, hh = w / 2, h / 2
    return text.printRich(txt, font, x, y, w / s, align, 0, s, s)
end


---@param constraint {get:fun(self:any):(number,number,number,number)}
---@param txt string
---@param font love.Font
---@param align love.AlignMode
---@param s number
local function printRichTextCenteredByConstraint(constraint, txt, font, align, s, rot)
    local x, y, w, h = constraint:get()
    local hw, hh = w / 2, h / 2
    return text.printRichCentered(txt, font, x + hw, y + hh, 0xffff, align, rot, s,s)
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


local function getAccumTextRotAndScale(timeSinceChange)
    -- jolt is number from 0 -> 1, representing how "far" along the jolt we are
    local jolt = math.clamp((ACCUMULATED_JOLT_DURATION - timeSinceChange) / ACCUMULATED_JOLT_DURATION, 0,1)

    local rot = -(jolt * ACCUMULATED_JOLT_ROTATION_AMOUNT)
    local scale = math.min(jolt, 1-jolt) * ACCUMULATED_JOLT_SCALE_BULGE_AMOUNT
    return rot, 1+scale
end


local BONUS_TEXT = interp("(%{val} Bonus)")

function LPState:drawHUD()
    local run = lp.singleplayer.getRun()
    if not run then return end

    local gs = globalScale.get()

    local font = fonts.getSmallFont(32)
    local largerFont = fonts.getSmallFont(64)

    local points = run:getAttribute("POINTS")
    local requiredPoints = run:getAttribute("REQUIRED_POINTS")
    local round = run:getAttribute("ROUND")
    local numberOfRounds = run:getAttribute("NUMBER_OF_ROUNDS")

    -- draw text on the left
    -- (Round/Level, money, points/required points)
    do
    local colorEffect
    if points >= requiredPoints then
        colorEffect = "{c r=0.1 g=1 b=0.2}"
    elseif points < 0 then
        colorEffect = "{c r=1 g=0.2 b=0.1}"
    else
        colorEffect = "{c r=1 g=1 b=1}"
    end

    local pointsText = POINTS_NORMAL({
        colorEffect = colorEffect,
        points = showNSignificant(points, 3),
        requiredPoints = requiredPoints,
    })

    local roundTextMaker
    if round > numberOfRounds and points >= requiredPoints then
        roundTextMaker = LEVEL_COMPLETE

    elseif round > numberOfRounds and points < requiredPoints then
        roundTextMaker = GAME_OVER
    elseif round >= numberOfRounds and points < requiredPoints then
        roundTextMaker = FINAL_ROUND_LEVEL
    else
        roundTextMaker = ROUND_AND_LEVEL
    end
    local roundText = roundTextMaker({
        round = round,
        numberOfRounds = numberOfRounds,
        level = run:getAttribute("LEVEL")
    })

    local moneyText = MONEY({money = run:getAttribute("MONEY")})

    local fH = font:getHeight()
    local TXT_PAD = 10 * gs
    love.graphics.setColor(1, 1, 1)
    text.printRich(roundText, font,  TXT_PAD, TXT_PAD + (fH+TXT_PAD)*0, 0xfffff, "left", 0, gs, gs)
    text.printRich(pointsText, font, TXT_PAD, TXT_PAD + (fH+TXT_PAD)*1, 0xfffff, "left", 0, gs, gs)
    text.printRich(moneyText, font,  TXT_PAD, TXT_PAD + (fH+TXT_PAD)*2, 0xfffff, "left", 0, gs, gs)
    end

    -- draw text on the right
    -- (Bonus, mult, points-accumulated)
    do
    local TXT_PAD = 10

    local currentTextY = TXT_PAD*gs

    local function drawOnRight(effectTxt, txt, xtraRot, xtraScale)
        -- We pass the effectTxt in manually because we need to compute the width

        -- effectTxt MUST NOT contain anything other than effects!!!
        -- Or else the width will be bugged
        local w = largerFont:getWidth(txt)
        local h = largerFont:getHeight()
        local s = gs
        local x = love.graphics.getWidth() - (w/2 + TXT_PAD*2)*gs
        text.printRichCentered(
            effectTxt .. txt, largerFont, x, currentTextY + h/2,
            0xffffff, "left",
            xtraRot, s*xtraScale, s*xtraScale
        )

        currentTextY = currentTextY + h*gs
    end

    local accumPointsText = showNSignificant(self.accumulatedPoints.accumulated, 3)
    if self.accumulatedPoints.timeout > 0 then
        local opacity = easeOutQuad(math.clamp(self.accumulatedPoints.timeout / ACCUMULATED_POINT_FADE_OUT, 0, 1))
        local richText = string.format("{wavy}{outline thickness=%.2f}", opacity * 4)

        local col
        if self.accumulatedPoints.accumulated < 0 then
            col = lp.COLORS.BAD_COLOR
        else
            col = lp.COLORS.POINTS_COLOR
        end
        love.graphics.setColor(col[1], col[2], col[3], opacity)

        local timeSincePointsChange = ACCUMULATED_POINT_TOTAL_TIME - self.accumulatedPoints.timeout
        local pRot, pScale = getAccumTextRotAndScale(timeSincePointsChange)
        drawOnRight(richText, accumPointsText, pRot, pScale)
    end

    local pBonus = self.bonusEffect.last
    if pBonus ~= 0 then
        local bonusVal
        if pBonus > 0 then
            love.graphics.setColor(lp.COLORS.BONUS_COLOR)
            bonusVal = "+"..showNSignificant(pBonus, 1)
        elseif pBonus < 0 then
            love.graphics.setColor(lp.COLORS.BAD_COLOR)
            bonusVal = "-"..showNSignificant(-pBonus, 1)
        end
        local bonText = BONUS_TEXT({
            val = bonusVal
        })
        local timeSinceBonusChange = ACCUMULATED_JOLT_DURATION - self.multiplierEffect.timeout
        local r, sc = getAccumTextRotAndScale(timeSinceBonusChange)
        drawOnRight("{wavy}{outline thickness=4}", bonText, r, sc)
    end

    local pointMul = self.multiplierEffect.last
    if pointMul ~= 1 then
        local mulText = "(x"..showNSignificant(pointMul, 1)..")"
        local timeSinceMultChange = ACCUMULATED_JOLT_DURATION - self.multiplierEffect.timeout
        local multRot, multScale = getAccumTextRotAndScale(timeSinceMultChange)
        love.graphics.setColor(lp.COLORS.POINTS_MULT_COLOR)
        drawOnRight("{wavy}{outline thickness=4}", mulText, multRot, multScale)
    end

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
