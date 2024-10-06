local fonts = require("client.fonts")

local lg=love.graphics

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")


---@class lootplot.main.NewRunScene: Element
local NewRunScene = ui.Element("lootplot.main:NewRunScene")

local FONT_SIZE = 32

---@param args table
function NewRunScene:init(args)
    local e = {}
    local BACKGROUND_COLOR = {objects.Color.HSLtoRGB(250, 0.1, 0.32)}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR
    })
    e.title = ui.elements.Text({
        text = "New Run",
        color = objects.Color.WHITE,
        outline=2,
        outlineColor = objects.Color.BLACK,
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.startButton = StretchableButton({
        onClick = function() end,
        text = "Start Run",
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.perkText = ui.elements.Text({
        text = "Perk",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color.WHITE,
        font = fonts.getSmallFont(FONT_SIZE),
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
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
    local scale = math.min(w/limit, h/th)
    local drawX, drawY = math.floor(x+w/2), math.floor(y+h/2)
    lg.printf(textString, font, drawX, drawY, limit, "left", 0, scale, scale, tw/2, th/2)
end



---@param region layout.Region
local function drawRectangleByConstraint(region)
    return love.graphics.rectangle("line", region:get())
end

local function drawRegions(rlist)
    love.graphics.setColor(0,1,1)
    for _, r in ipairs(rlist) do
        love.graphics.rectangle("line", r:get())
    end
    love.graphics.setColor(1,1,1)
end

function NewRunScene:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h)
    local title, body, startButton, _ = r:splitVertical(0.07, 0.8, 0.13)
    body = body:padRatio(0.05)
    title = title:padRatio(0.33, 0.1, 0.33, 0.1)
        :moveRatio(0, 0.5 + math.sin(love.timer.getTime())/6)

    startButton = startButton:shrinkToAspectRatio(3,1):padRatio(0.1,0.2)

    local leftBody, rightBody = body:splitHorizontal(2, 1)

    leftBody = leftBody:padRatio(0.1)
    local perkBox, lowerBox = leftBody:splitVertical(1, 2)
    local perkImage, perkDescription = perkBox:splitHorizontal(2, 5)
    perkImage = perkImage:shrinkToAspectRatio(1,1)
    local perkText = perkImage:shrinkToAspectRatio(4,1)
        :attachToTopOf(perkImage)
        :moveRatio(0, 0.5 + math.sin(love.timer.getTime() * 3)/6)
        -- ^^^ make it bob up and down yo!

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.startButton:render(startButton:get())
    self.elements.perkText:render(perkText:get())

    drawTextIn("Golden-perk:\nStart the game with 3 extra shop slots", perkDescription)

    local DEBUG=false
    if DEBUG then
        drawRegions({
            r,
            body,title,startButton,
            leftBody,rightBody,
            perkBox,lowerBox,
            perkImage,perkText,perkDescription
        })
    end

    love.graphics.setColor(objects.Color.WHITE)
    drawRectangleByConstraint(perkImage)

    drawRectangleByConstraint(rightBody)
end

return NewRunScene
