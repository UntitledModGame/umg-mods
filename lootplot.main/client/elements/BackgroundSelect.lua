local fonts = require("client.fonts")

---@class lootplot.main.BackgroundSelect: Element
local BackgroundSelect = ui.Element("lootplot.main:BackgroundSelect")

local BACKGROUND_ANIM_TIME = 0.1
local LOWEST_INDEX = 2
local BACKGROUND_DRAW_ORDER = {-2, 2, -1, 1, 0}
local FONT_SIZE = 32
local LOWEST_INDEX_PLUS_1 = LOWEST_INDEX + 1

---@param a integer
---@param b integer
local function moduloBy1(a, b)
    return (a - 1) % b + 1
end

---@param bgs lootplot.backgrounds.BackgroundInfoData[]
---@param lastSelect string
function BackgroundSelect:init(bgs, lastSelect)
    self.backgrounds = bgs
    self.backgroundIndexFloat = 1
    self.backgroundAnimStart = 0 -- if above 0, move according to "direction"
    self.backgroundAnimDir = 0 -- 1 = right to left, -1 = left to right

    for i, bg in ipairs(self.backgrounds) do
        if bg.id == lastSelect then
            self.backgroundIndexFloat = i
            break
        end
    end

    local e = {}
    e.backgroundPrev = ui.elements.Button({
        click = function()
            if self.backgroundAnimStart <= 0 then
                self.backgroundAnimStart = BACKGROUND_ANIM_TIME
                self.backgroundAnimDir = -1
            end
        end,
        image = client.assets.images.prev_list_button
    })
    e.backgroundNext = ui.elements.Button({
        click = function()
            if self.backgroundAnimStart <= 0 then
                self.backgroundAnimStart = BACKGROUND_ANIM_TIME
                self.backgroundAnimDir = 1
            end
        end,
        image = client.assets.images.next_list_button
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

function BackgroundSelect:onUpdate(dt)
    -- Update background animation
    if self.backgroundAnimStart > 0 then
        self.backgroundAnimStart = self.backgroundAnimStart - dt
    end

    if self.backgroundAnimStart > 0 then
        self.backgroundIndexFloat = self.backgroundIndexFloat + dt * self.backgroundAnimDir / BACKGROUND_ANIM_TIME
    else
        if self.backgroundAnimDir > 0 then
            self.backgroundIndexFloat = math.floor(self.backgroundIndexFloat + 0.5)
        elseif self.backgroundAnimDir < 0 then
            self.backgroundIndexFloat = math.ceil(self.backgroundIndexFloat - 0.5)
        end

        self.backgroundAnimDir = 0
    end

    self.backgroundIndexFloat = moduloBy1(self.backgroundIndexFloat, #self.backgrounds)
end

function BackgroundSelect:getSelectedBackgroundIndex()
    local index = self.backgroundIndexFloat
    if self.backgroundAnimDir > 0 then
        index = math.ceil(index)
    elseif self.backgroundAnimDir < 0 then
        index = math.floor(index)
    end

    return math.floor(moduloBy1(index, #self.backgrounds)) -- another math.floor just to be safe
end

---@return lootplot.backgrounds.BackgroundInfoData
function BackgroundSelect:getSelectedBackground()
    return assert(self.backgrounds[self:getSelectedBackgroundIndex()])
end



---@param font love.Font
---@param text string
---@param wrap number?
---@return number,number
local function getTextSize(font, text, wrap)
    local width, lines = font:getWrap(text, wrap or 2147483647)
    return width, #lines * font:getHeight()
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
    love.graphics.printf(textString, font, drawX, drawY, limit, "left", 0, scale, scale, tw/2, th/2)
end

function BackgroundSelect:onRender(x, y, w, h)
    local root = layout.Region(x, y, w, h)
    local e = self.elements

    local bgName, bgSelectBase = root:splitVertical(1, 2)
    local bgButtonLeft, bgList, bgButtonRight = bgSelectBase:splitHorizontal(1, 4, 1)

    local currentSelectedIndex = self:getSelectedBackgroundIndex()
    local bg = self.backgrounds[currentSelectedIndex]
    drawTextIn(bg.name, bgName)

    e.backgroundPrev:render(bgButtonLeft:get())
    e.backgroundNext:render(bgButtonRight:get())

    bgList = bgList:padRatio(0.2, 0, 0.2, 0)
    local halfWidth = bgList.w / 2
    local drawY = bgList.y + bgList.h / 2

    for _, relidx in ipairs(BACKGROUND_DRAW_ORDER) do
        local fract = self.backgroundIndexFloat % 1
        local tbdIndex = moduloBy1(currentSelectedIndex + relidx, #self.backgrounds)
        if self.backgroundAnimDir > 0 and self.backgroundAnimStart < BACKGROUND_ANIM_TIME then
            -- Note: Need to -1 here because the getSelectedBackgroundIndex() will ceil()
            -- which means it returns the next selected directly, but we're still interpolating.
            tbdIndex = moduloBy1(tbdIndex - 1, #self.backgrounds)
        end

        local drawX = bgList.x + halfWidth + (relidx - fract) * halfWidth / LOWEST_INDEX
        local baseScale = (LOWEST_INDEX_PLUS_1 - math.abs(relidx - fract)) / LOWEST_INDEX_PLUS_1
        local scale = bgList.h * baseScale / 16
        rendering.drawImage(self.backgrounds[tbdIndex].icon, drawX, drawY, 0, scale, scale)
    end
end

return BackgroundSelect