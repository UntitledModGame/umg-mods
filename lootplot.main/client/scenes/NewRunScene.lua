
local fonts = require("client.fonts")
local lg=love.graphics
local globalScale = require("client.globalScale")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")

local PerkSelect = require("client.elements.PerkSelect")


local loc = localization.localize

local NEW_RUN_STRING = loc("New Run")
local NEW_RUN_BUTTON_STRING = loc("Start New Run")

local CHOOSE_UR_STARTING_ITEM = loc("Choose your starting item!")



---@class lootplot.main.NewRunScene: Element
local NewRunScene = ui.Element("lootplot.main:NewRunScene")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))
local KEYS = {
    startNewRun = true,
    backgrounds = true, -- lootplot.backgrounds.BackgroundInfoData[]
    lastSelectedBackground = true -- string (ID of background)
}

local FOREGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.14))
local BACKGROUND_ANIM_TIME = 0.5

function NewRunScene:init(arg)
    typecheck.assertKeys(arg, KEYS)

    ---@type lootplot.backgrounds.BackgroundInfoData[]
    self.backgrounds = arg.backgrounds
    self.backgroundIndexFloat = 1
    self.backgroundAnimStart = 0 -- if above 0, move according to "direction"
    self.backgroundAnimDir = 0 -- 1 = right to left, -1 = left to right

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
            local itemEType = self:getSelectedPerkItem()
            if not itemEType then
                umg.log.fatal("WOT WOT????")
                return
            end
            local typName = itemEType:getTypename()
            assert(itemEType:getEntityMt())
            return arg.startNewRun(assert(typName))
        end,
        text = NEW_RUN_BUTTON_STRING,
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })

    if arg.cancelRun then
        e.cancelButton = ui.elements.Button({
            click = arg.cancelRun,
            image = "red_square_1",
            backgroundColor = objects.Color.TRANSPARENT,
            outlineColor = objects.Color.TRANSPARENT
        })
    end

    self.perkSelect = PerkSelect()
    e.perkSelectBox = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = FOREGROUND_COLOR,
        scale = 1
    })
    e.scrollBox = ui.elements.ScrollBox({
        content = self.perkSelect
    })

    e.backgroundBox = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = FOREGROUND_COLOR,
        scale = 1
    })
    e.backgroundPrev = ui.elements.Button({
        click = function()
            if self.backgroundAnimStart <= 0 then
                self.backgroundAnimDir = -1
                self.backgroundAnimStart = BACKGROUND_ANIM_TIME
            end
        end,
        image = client.assets.images.prev_list_button
    })
    e.backgroundNext = ui.elements.Button({
        click = function()
            if self.backgroundAnimStart <= 0 then
                self.backgroundAnimDir = 1
                self.backgroundAnimStart = BACKGROUND_ANIM_TIME
            end
        end,
        image = client.assets.images.next_list_button
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end


---@param a integer
---@param b integer
local function moduloBy1(a, b)
    return (a - 1) % b + 1
end

function NewRunScene:onUpdate(dt)
    -- Update background animation
    if self.backgroundAnimStart > 0 then
        self.backgroundIndexFloat = self.backgroundIndexFloat + dt * self.backgroundAnimDir / BACKGROUND_ANIM_TIME
        self.backgroundAnimStart = self.backgroundAnimStart - dt
    else
        if self.backgroundAnimDir > 0 then
            self.backgroundIndexFloat = math.floor(self.backgroundIndexFloat)
        elseif self.backgroundAnimDir < 0 then
            self.backgroundIndexFloat = math.ceil(self.backgroundIndexFloat)
        end

        self.backgroundAnimDir = 0
    end

    self.backgroundIndexFloat = moduloBy1(self.backgroundIndexFloat, #self.backgrounds)
end



function NewRunScene:getSelectedPerkItem()
    return self.perkSelect:getSelectedItem()
end

function NewRunScene:getSelectedBackground()
    local index = self.backgroundIndexFloat
    if self.backgroundAnimDir > 0 then
        index = math.ceil(index)
    elseif self.backgroundAnimDir < 0 then
        index = math.floor(index)
    end

    return math.floor(moduloBy1(index, #self.backgrounds)) -- another math.floor just to be safe
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



---@param region layout.Region
local function bob(region, amp, speed)
    return region:moveRatio(0, (amp or 0.1) * math.sin(love.timer.getTime() * (speed or 1)))
end

local LOWEST_INDEX = 2
local BACKGROUND_DRAW_ORDER = {-2, 2, -1, 1, 0}

function NewRunScene:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.15, 0.1)
    local e = self.elements

    local title, body, footer = r:splitVertical(1, 4, 1)
    body = body:padRatio(0.1)
    title = bob(title:padRatio(0.1))

    local left, right = body:splitHorizontal(1, 1)
    left = left:padRatio(0.1)
    right = right:padRatio(0.1)

    local cancelButton = nil
    if e.cancelButton then
        local iw, ih = select(3, client.assets.images.red_square_1:getViewport())
        local s = globalScale.get() * 2
        local regW, regH = iw * s, ih * s
        local pad = 5
        cancelButton = layout.Region(0, 0, regW, regH)
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
        local etype = self:getSelectedPerkItem() or {}
        drawTextIn(etype.name or "?", bob(perkName, 0.1, 2.3))
        drawTextIn(etype.description or "???", perkDesc:padRatio(0.1))
        if etype.image then
            ui.drawImageInBox(client.assets.images[etype.image], perkImg:get())
        end
    end

    -- background:
    e.backgroundBox:render(backgroundBox:get())
    local bgName, bgSelectBase = backgroundBox:padRatio(0.1):splitVertical(1, 2)
    local bgButtonLeft, bgList, bgButtonRight = bgSelectBase:splitHorizontal(1, 4, 1)

    local currentSelectedIndex = self:getSelectedBackground()
    drawTextIn(self.backgrounds[currentSelectedIndex].name, bgName)

    e.backgroundPrev:render(bgButtonLeft:get())
    e.backgroundNext:render(bgButtonRight:get())

    bgList = bgList:padRatio(0.2, 0, 0.2, 0)
    local halfWidth = bgList.w / 2
    local drawY = bgList.y + bgList.h / 2
    local LOWEST_INDEX_PLUS_1 = LOWEST_INDEX + 1

    for _, relidx in ipairs(BACKGROUND_DRAW_ORDER) do
        local fract = self.backgroundIndexFloat % 1
        local tbdIndex = moduloBy1(currentSelectedIndex + relidx, #self.backgrounds)

        local drawX = bgList.x + halfWidth + (relidx + fract) * halfWidth / LOWEST_INDEX
        local baseScale = (LOWEST_INDEX_PLUS_1 - math.abs(relidx + fract)) / LOWEST_INDEX_PLUS_1
        local scale = bgList.h * baseScale / (16 * LOWEST_INDEX)
        rendering.drawImage(self.backgrounds[tbdIndex].icon, drawX, drawY, 0, scale, scale)
    end
    print(self.backgroundIndexFloat)
    drawRegions {bgButtonLeft, bgButtonRight, bgList}

    -- selection:
    local perkSelectTitle, perkSelect = right:splitVertical(1,6)
    drawTextIn(CHOOSE_UR_STARTING_ITEM, perkSelectTitle)
    e.perkSelectBox:render(perkSelect:get())
    e.scrollBox:render(perkSelect:padRatio(0.2):get())

    -- start button:
    local startButton = footer:padRatio(0.15):shrinkToAspectRatio(4,1)
    if self:getSelectedPerkItem() then
        e.newRunButton:render(startButton:get())
    end

    if e.cancelButton and cancelButton then
        e.cancelButton:render(cancelButton:get())
    end

    -- pane separator:
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)

    --[=[
    -- DEBUG ONLY
    drawRegions({
        r,
        body,title,startButton,
        left,right,
        perkBox,selectBox,
        perkImg,perkText,perkDesc
    })
    ]=]
end

return NewRunScene

