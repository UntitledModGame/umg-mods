
local fonts = require("client.fonts")
local globalScale = require("client.globalScale")
local lg=love.graphics

local runManager = require("shared.run_manager")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")


local loc = localization.localize

local NEW_RUN_STRING = loc("New Run")




---@class lootplot.main.NewRunDialog: Element
local NewRunDialog = ui.Element("lootplot.main:NewRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))

function NewRunDialog:init()
    local e = {}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR,
        scale = 2
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
            return runManager.startRun({
                starterItem = "one_ball",
                seed = "123",
            })
        end,
        text = "Start New Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
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
    local scale = math.min(w/tw, h/th)
    local drawX, drawY = math.floor(x+w/2), math.floor(y+h/2)
    lg.printf(textString, font, drawX, drawY, limit, "left", 0, scale, scale, tw/2, th/2)
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

function NewRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.15, 0.1)

    local title, body, footer = r:splitVertical(1, 4, 1)
    body = body:padRatio(0.1)
    title = bob(title:padRatio(0.1))
        
    local left, right = body:splitHorizontal(1, 1)

    -- background:
    self.elements.base:render(r:get())

    local perkBox, seedBox, bottomBox = left:splitVertical(4,1,4)
    -- perk:
    local perkImg, perkText = perkBox:padRatio(0.1):splitHorizontal(1,3)
    local perkName, perkDesc = perkText:splitVertical(1,4)
    perkImg = perkImg:shrinkToAspectRatio(1,1)
    drawTextIn("My Perk", bob(perkName, 0.1, 2.3))
    drawTextIn(
        "This is a big perk description. I am intentionally making it big to test text wrapping", 
        perkDesc:padRatio(0.1)
    )
    ui.drawImageInBox(client.assets.images.one_ball, perkImg:get())

    -- selection:
    local selectTitle, selectBox = right:splitHorizontal(0.2,1)
    self.elements.title:render(title:get())

    -- start button:
    local startButton = footer:padRatio(0.15):shrinkToAspectRatio(4,1)
    self.elements.newRunButton:render(startButton:get())

    -- pane separator:
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)

    local DEBUG=true
    if DEBUG then
        drawRegions({
            r,
            body,title,startButton,
            left,right,
            perkBox,selectBox,
            perkImg,perkText,perkDesc
        })
    end
end

return NewRunDialog
