
local fonts = require("client.fonts")
local lg=love.graphics
local globalScale = require("client.globalScale")
local helper = require("client.states.helper")


local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")

local DifficultySelect = require("client.elements.DifficultySelect")
local BackgroundSelect = require("client.elements.BackgroundSelect")
local PerkSelect = require("client.elements.PerkSelect")



local NUM_DEMO_WINS = 2
--[[
2 wins before the demo doesn't allow players to play anymore.
]]


local loc = localization.localize

local NEW_RUN_STRING = loc("New Run")
local NEW_RUN_BUTTON_STRING = loc("Start New Run")

local NEW_RUN_DEMO_LOCKED = loc("Buy full game to continue!")


local CHOOSE_UR_STARTING_ITEM = loc("Choose your starting item!")



---@class lootplot.singleplayer.NewRunScene: Element
local NewRunScene = ui.Element("lootplot.singleplayer:NewRunScene")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))
local KEYS = {
    "startNewRun",
    "backgrounds", -- lootplot.backgrounds.BackgroundInfoData[]
    "lastSelectedBackground", -- string (ID of background)
    "exit"
}

local FOREGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.14))

function NewRunScene:init(arg)
    typecheck.assertKeys(arg, KEYS)

    self.isQuitting = false

    local e = {}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR,
        scale = 1
    })
    e.perkBox = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = FOREGROUND_COLOR,
        scale = 1
    })
    e.title = ui.elements.Text({
        text = NEW_RUN_STRING,
        color = objects.Color.WHITE,
        outline = 2,
        outlineColor = objects.Color.BLACK,
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.newRunButton = StretchableButton({
        onClick = function()
            local itemEType = self:getSelectedStarterItem()
            if not itemEType then
                umg.log.fatal("WOT WOT????")
                return
            end
            local typName = itemEType:getTypename()
            assert(itemEType:getEntityMetatable())
            return arg.startNewRun(assert(typName), self:getSelectedBackground(), self:getSelectedDifficulty())
        end,
        text = NEW_RUN_BUTTON_STRING,
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })

    e.exitButton = ui.elements.Button({
        click = function()
            self.isQuitting = true
            arg.exit()
        end,
        image = "red_square_1",
        backgroundColor = objects.Color.TRANSPARENT,
        outlineColor = objects.Color.TRANSPARENT
    })

    self.perkSelect = PerkSelect()
    e.perkSelect = self.perkSelect

    e.perkSelectBox = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = FOREGROUND_COLOR,
        scale = 1
    })

    e.diffSelect = DifficultySelect(self)

    ---@type lootplot.singleplayer.BackgroundSelect
    e.bgSelect = BackgroundSelect(arg.backgrounds, arg.lastSelectedBackground)
    e.backgroundBox = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = FOREGROUND_COLOR,
        scale = 1
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end



function NewRunScene:getSelectedStarterItem()
    return self.perkSelect:getSelectedItem()
end

function NewRunScene:getSelectedBackground()
    return self.elements.bgSelect:getSelectedBackground().id
end



---@param font love.Font
---@param text string
---@param wrap number?
---@return number,number
local function getTextSize(font, text, wrap)
    local width, lines = font:getWrap(text, wrap or 2147483647)
    return width, #lines * font:getHeight()
end


local function drawRegions(rlist)
    love.graphics.setColor(0,1,1)
    for _, r in ipairs(rlist) do
        love.graphics.rectangle("line", r:get())
    end
    love.graphics.setColor(1,1,1)
end



---@param textString string
---@param region layout.Region
local function drawTextIn(textString, region)
    local x,y,w,h = region:get()
    local font = fonts.getSmallFont(FONT_SIZE)
    local limit = w
    local tw, th = getTextSize(font, textString, limit)

    -- scale text to fit box
    local scale = math.min(w/tw, h/th)
    local drawX, drawY = math.floor(x+w/2), math.floor(y+h/2)
    lg.printf(textString, font, drawX, drawY, limit, "left", 0, scale, scale, tw/2, th/2)
end



function NewRunScene:getSelectedDifficulty()
    return self.elements.diffSelect:getSelectedDifficulty()
end



---@param region layout.Region
local function bob(region, amp, speed)
    return region:moveRatio(0, (amp or 0.1) * math.sin(love.timer.getTime() * (speed or 1)))
end

function NewRunScene:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.15, 0.1)
    local e = self.elements

    if self.isQuitting then
        helper.drawQuittingScreen(x,y,w,h)
        return
    end

    local title, body, footer = r:splitVertical(1, 4, 1)
    body = body:padRatio(0.1)
    title = bob(title:padRatio(0.1))

    local left, right = body:splitHorizontal(1, 1)
    left = left:padRatio(0.1)
    right = right:padRatio(0.1)

    local exitButton = nil
    if e.exitButton then
        local iw, ih = select(3, client.assets.images.red_square_1:getViewport())
        local s = globalScale.get() * 2
        local regW, regH = iw * s, ih * s
        local pad = 5
        exitButton = layout.Region(0, 0, regW, regH)
            :attachToRightOf(r)
            :attachToTopOf(r)
            :moveUnit(-regW - pad, regH + pad)
    end

    e.base:render(r:get())

    e.title:render(title:get())

    local perkBox, backgroundBox = left:splitVertical(4,5)
    -- perk:
    local perkImg, perkText = perkBox:padRatio(0.1):splitHorizontal(1,3)
    local perkName, perkDesc = perkText:splitVertical(1,2)
    perkImg = bob(perkImg:padRatio(0.2):shrinkToAspectRatio(1,1), 0.1, 1.5)
    e.perkBox:render(perkBox:get())
    do
        local etype = self:getSelectedStarterItem() or {}
        drawTextIn(etype.name or "?", bob(perkName, 0.1, 2.3))
        drawTextIn(etype.description or "???", perkDesc:padRatio(0.1))
        if etype.image then
            ui.drawImageInBox(client.assets.images[etype.image], perkImg:get())
        end
    end

    -- background:
    e.backgroundBox:render(backgroundBox:get())
    e.bgSelect:render(backgroundBox:padRatio(0.1):get())

    local perkSelectTitle, perkSelect, difficultySelect = right:splitVertical(1,5,3)
    -- selection:
    drawTextIn(CHOOSE_UR_STARTING_ITEM, perkSelectTitle)
    e.perkSelectBox:render(perkSelect:get())
    e.perkSelect:render(perkSelect:padRatio(0.2):get())

    -- difficulty:
    love.graphics.setColor(1,1,1)
    e.diffSelect:render(difficultySelect:get())

    -- start button:
    local isDemoComplete = umg.DEMO_MODE and (lp.getWinCount() >= NUM_DEMO_WINS)
    if isDemoComplete then
        local demoLockTxt = footer:padRatio(0.3)
        text.printRichContained("{outline thickness=1}" .. NEW_RUN_DEMO_LOCKED, fonts.getLargeFont(16), demoLockTxt:get())
    else
        local startButton = footer:padRatio(0.15):shrinkToAspectRatio(4,1)
        if self:getSelectedStarterItem() then
            e.newRunButton:render(startButton:get())
        end
    end

    -- exit button
    if e.exitButton and exitButton then
        e.exitButton:render(exitButton:get())
    end

    -- pane separator:
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)
end

return NewRunScene

