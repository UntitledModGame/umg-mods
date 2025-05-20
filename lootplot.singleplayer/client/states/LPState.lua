
local Scene = require("client.scenes.LPScene")
local globalScale = require("client.globalScale")
local fonts = require("client.fonts")

local helper = require("client.states.helper")




local lg = love.graphics

local loc = localization.localize


---@class lootplot.singleplayer.LPState: objects.Class, state.IState
local LPState = objects.Class("lootplot.singleplayer:State")


-- This global-state is kinda bad, but we need it 
-- due to the global-nature of base lootplot evbuses
---@type lootplot.singleplayer.LPState
local lpState = nil


-- (action button stuff)
---@param selection lootplot.Selected
umg.on("lootplot:selectionChanged", function(selection)
    if lpState then
        local scene = lpState:getScene()
        scene:setSelection(selection)
    end
end)


umg.on("lootplot:winGame", function(...)
    if lpState then
        local scene = lpState:getScene()
        scene:winGame()
        lpState:winGame()
    end
end)

umg.on("lootplot:loseGame", function(...)
    if lpState then
        local scene = lpState:getScene()
        scene:loseGame()
    end
end)


umg.on("lootplot:pointsChanged", function(ent, delta, oldVal, newVal)
    if lpState then
        lpState:pointsChanged(ent, delta, oldVal, newVal)
    end
end)

umg.on("lootplot:attributeChanged", function(attr, _ent, delta)
    if lpState and (attr == "LEVEL") and delta > 0 then
        lpState:levelUp()
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

    self.showWinScreen = false
    self.winQuitButtonRegion = nil

    self.shockwave = nil
    -- a shockwave that occurs when player breaches point requirement, 
    -- OR on level-up

    self.isQuitting = false

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



local INFINITY = loc("INFINITY")
local NEGATIVE_INFINITY = loc("-INFINITY")

local function isInfinity(x)
    local isNan = x ~= x
    local isInf = (x == math.huge) or (x == -math.huge)
    return isNan or isInf
end


-- After this, should go into `1.32434e15` territory.
local MAX_ZEROS = 11

---@param value number
---@param nsig integer
---@return string
local function showNSignificant(value, nsig)
    if isInfinity(value) then
        return INFINITY
    elseif (value == -math.huge) then
        return NEGATIVE_INFINITY
    end
	local zeros = math.floor(math.log10(math.max(math.abs(value), 1)))
    if zeros >= MAX_ZEROS then
        local normalized = value / (10^zeros)
        return tostring(showNSignificant(normalized, nsig)) .. " e" .. zeros
    end
	local mulby = 10 ^ math.max(nsig - zeros, 0)
	return tostring(math.floor(value * mulby) / mulby)
end

local ACCUMULATED_POINT_FADE_OUT = 0.3
local ACCUMULATED_POINT_TOTAL_TIME = 2

local ACCUMULATED_JOLT_DURATION = 0.2 -- in seconds

local ACCUMULATED_JOLT_ROTATION_AMOUNT = math.rad(20)
local ACCUMULATED_JOLT_SCALE_BULGE_AMOUNT = 1.2



---@param self lootplot.singleplayer.LPState
---@param color objects.Color
---@param thickness number? Number from 0->1 denoting thickness of sw.
local function createShockwave(self, color, thickness)
    self.shockwave = {
        time = 0,
        color = color,
        thickness = (thickness or 1) * 80
    }
end

-- grows 140% of the screen per second
local SHOCKWAVE_GROW_SPEED = 2.2
local SHOCKWAVE_DURATION = 2 -- lives for X seconds

---@param self lootplot.singleplayer.LPState
local function drawShockwave(self)
    if not self.shockwave then
        return
    end
    local w,h = lg.getDimensions()
    local centerX, centerY = w/6,h/6
    local radius = (w * SHOCKWAVE_GROW_SPEED) * self.shockwave.time
    local oldLineWidth = lg.getLineWidth()
    local sc = globalScale.get()
    local width = self.shockwave.thickness * sc
    lg.setLineWidth(width)
    local c = self.shockwave.color
    local r,g,b = c[1],c[2],c[3]
    lg.setColor(r,g,b,1)
    lg.circle("line", centerX, centerY, radius)
    lg.setLineWidth(oldLineWidth)
end




function LPState:pointsChanged(ent, deltaPoints, oldVal, newVal)
    self.accumulatedPoints.accumulated = self.accumulatedPoints.accumulated + deltaPoints
    self.accumulatedPoints.timeout = ACCUMULATED_POINT_TOTAL_TIME

    local pointsReq = lp.getRequiredPoints(ent)
    if pointsReq and pointsReq > oldVal and pointsReq <= newVal then
        -- then we have breached the boundary! Hallelujah!
        -- send out a shockwave and stuff
        createShockwave(self, objects.Color.GREEN, 0.8)
    end
end


function LPState:update(dt)
    if self.shockwave then
        self.shockwave.time = self.shockwave.time + dt
        if self.shockwave.time > SHOCKWAVE_DURATION then
            self.shockwave = nil
        end
    end

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

local LEVEL_NON_FINAL = interp("Level %{level}")
local LEVEL_FINAL = interp("{c r=1 g=0.2 b=0.2}FINAL LEVEL! (%{level}){/c}")

local ROUND_AND_LEVEL = interp("{wavy amp=0.5 k=0.5}{outline thickness=2}Round %{round}/%{numberOfRounds} - %{levelText}")
local FINAL_ROUND_LEVEL = interp("{wavy freq=2.5 amp=0.75 k=1}{outline thickness=2}{c r=1 g=0.2 b=0.1}FINAL ROUND %{round}/%{numberOfRounds}{/outline}{/wavy}{wavy amp=0.5 k=0.5}{outline thickness=2} - %{levelText}")
local LEVEL_COMPLETE = interp("{c r=0.2 g=1 b=0.4}{wavy amp=0.5 k=0.5}{outline thickness=2}Level %{level} Complete!")
local GAME_OVER = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}{c r=0.7 g=0.1 b=0}GAME OVER! (Level %{level})")

local POINTS_NORMAL = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline thickness=2}Points: %{colorEffect}%{points} {c r=1 g=1 b=1}/{/c} %{requiredPoints}")
local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline thickness=2}%{colorEffect}$ %{money}")


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





local WIN_TEXT = loc("{wavy}{outline thickness=3}{c r=0.1 g=0.8 b=0.2}YOU WIN!")

local UNLOCKED_TXT = loc("{wavy}{outline thickness=2}New items have been unlocked!")
local SHARE_WITH_FRIENDS_TEXT = loc("{wavy}{outline thickness=2}Share LootPlot with others! It helps us a lot! :)")


---@param self lootplot.singleplayer.LPState
local function drawWinScreen(self)
    local font = fonts.getSmallFont(32)
    local largerFont = fonts.getSmallFont(64)

    local t = love.timer.getTime()

    local _
    local header, subheader, body, footer = layout.Region(0,0,love.graphics.getDimensions())
        :splitVertical(.25, 0.15, .4, 0.2)
    love.graphics.setColor(1,1,1)

    -- header
    do
    header = header:padRatio(0.1)
    local _, cat1, winText, cat2, _ = header:splitHorizontal(2, 1,3,1, 2)
    text.printRichContained(WIN_TEXT, largerFont, winText:get())
    local a,b,c,d = cat1:padRatio(0.3):get()
    ui.drawImageInBox("win_screen_cat", a,b,c,d, t*2)
    a,b,c,d = cat2:padRatio(0.3):get()
    ui.drawImageInBox("win_screen_cat", a,b,c,d, -t*2)
    end

    -- unlocked items text
    _, subheader, _ = subheader:splitHorizontal(1,4,1)
    subheader = subheader:moveRatio(0,-0.4):padRatio(0.2)
    if lp.getWinCount() < 10 then
        -- HACKY HARDCODE. Oh well
        text.printRichContained(UNLOCKED_TXT, font, subheader:get())
    else
        text.printRichContained(SHARE_WITH_FRIENDS_TEXT, font, subheader:get())
    end

    -- quit/claim trophy button
    local difficulty = lp.getDifficulty()
    if difficulty then
        local r0,r1, button, r2,r3 = footer:padRatio(0.1):splitHorizontal(1,1,3,1,1)
        self.winQuitButtonRegion = button

        local dInfo = lp.getDifficultyInfo(difficulty)
        if dInfo then
            local trophy = dInfo.image
            local AMP = 1/5
            ui.drawImageInBox(trophy, r0:padRatio(0.2):moveRatio(0,-0.1+math.sin(t*2+1)*AMP):get())
            ui.drawImageInBox(trophy, r1:padRatio(0.2):moveRatio(0,math.sin(t*2)*AMP):get())
            ui.drawImageInBox(trophy, r2:padRatio(0.2):moveRatio(0,math.sin(t*2)*AMP):get())
            ui.drawImageInBox(trophy, r3:padRatio(0.2):moveRatio(0,-0.1+math.sin(t*2+1)*AMP):get())
        end
    end
end




local BONUS_TEXT = interp("(%{val} Bonus)")

function LPState:drawHUD()
    local run = lp.singleplayer.getRun()
    if not run then return end

    local gs = globalScale.get()
    local font = fonts.getSmallFont(32)
    local largerFont = fonts.getSmallFont(64)

    self.winQuitButtonRegion = nil -- this is a bit hacky but oh well
    if self.showWinScreen then
        drawWinScreen(self)
        return
    end

    local points = run:getAttribute("POINTS")
    local requiredPoints = run:getAttribute("REQUIRED_POINTS")
    local round = run:getAttribute("ROUND")
    local numberOfRounds = run:getAttribute("NUMBER_OF_ROUNDS")
    local numberOfLevels = run:getAttribute("NUMBER_OF_LEVELS")
    local level = run:getAttribute("LEVEL")

    local isFinalLevel = numberOfLevels == level

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

    local levelText = ((isFinalLevel and LEVEL_FINAL) or LEVEL_NON_FINAL)({
        level = level
    })
    local roundText = roundTextMaker({
        round = round,
        levelText = levelText,
        numberOfRounds = numberOfRounds,
        level = level
    })

    local moneyText = MONEY({
        money = showNSignificant(run:getAttribute("MONEY"), 1),
        colorEffect = ((run:getAttribute("MONEY") >= 0) and "{c r=1 g=0.843 b=0.1}") or "{c r=0.9 g=0.15 b=0.1}"
    })

    local fH = font:getHeight() * gs
    local TXT_PAD = 1 * gs
    local LEFT_PAD = 10 * gs
    lg.setColor(1, 1, 1)
    text.printRich(roundText, font,  LEFT_PAD, TXT_PAD + (fH+TXT_PAD)*0, 0xfffff, "left", 0, gs, gs)
    text.printRich(pointsText, font, LEFT_PAD, TXT_PAD + (fH+TXT_PAD)*1, 0xfffff, "left", 0, gs, gs)
    text.printRich(moneyText, font,  LEFT_PAD, TXT_PAD + (fH+TXT_PAD)*2, 0xfffff, "left", 0, gs, gs)
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
        local x = lg.getWidth() - (w/2 + TXT_PAD*2)*gs
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
        lg.setColor(col[1], col[2], col[3], opacity)

        local timeSincePointsChange = ACCUMULATED_POINT_TOTAL_TIME - self.accumulatedPoints.timeout
        local pRot, pScale = getAccumTextRotAndScale(timeSincePointsChange)
        drawOnRight(richText, accumPointsText, pRot, pScale)
    end

    local pBonus = self.bonusEffect.last
    if pBonus ~= 0 then
        local bonusVal
        if pBonus > 0 then
            lg.setColor(lp.COLORS.BONUS_COLOR)
            bonusVal = "+"..showNSignificant(pBonus, 1)
        elseif pBonus < 0 then
            lg.setColor(lp.COLORS.BAD_COLOR)
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
        lg.setColor(lp.COLORS.POINTS_MULT_COLOR)
        drawOnRight("{wavy}{outline thickness=4}", mulText, multRot, multScale)
    end

    end

    drawShockwave(self)
end


function LPState:quitGame()
    self.isQuitting = true
    client.disconnect()
end



function LPState:winGame()
    createShockwave(self, objects.Color.GREEN, 1.2)
    self.showWinScreen = true
    self:getScene():winGame()
end


function LPState:loseGame()
    self:getScene():loseGame()
end



function LPState:levelUp()
    createShockwave(self, objects.Color(198/255, 81/255, 95/255), 1.2)
end



function LPState:draw()
    local x, y, w, h = love.window.getSafeArea()

    if self.isQuitting then
        helper.drawQuittingScreen(x, y, w, h)
        return
    end

    rendering.drawWorld()
    self.scene:render(x, y, w, h)
    if lp.singleplayer.isHUDEnabled() then
        self:drawHUD()
    end
    chat.getChatBoxElement():render(x, y, w, h)
end


function LPState:getScene()
    return self.scene
end

function LPState:getSpeedMultipler()
    return 2 ^ self.scene.gameSpeedMultiplerFactor
end

return LPState
