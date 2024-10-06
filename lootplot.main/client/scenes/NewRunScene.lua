local fonts = require("client.fonts")

local globalScale = require("client.globalScale")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")


---@class lootplot.main.NewRunScene: Element
local NewRunScene = ui.Element("lootplot.main:NewRunScene")

---@param args table
function NewRunScene:init(args)
    local e = {}
    e.base = StretchableBox("orange_pressed_big", 8, {
        stretchType = "repeat",
    })
    e.title = ui.elements.Text({
        text = "New Run",
        color = objects.Color.WHITE,
        font = fonts.getLargeFont(16),
        scale = globalScale.get()
    })
    e.startButton = StretchableButton({
        onClick = function() end,
        text = "Start Run",
        color = objects.Color.DARK_GREEN,
        font = fonts.getLargeFont(16),
        scale = globalScale.get
    })
    e.perkText = ui.elements.Text({
        text = "Perk",
        font = fonts.getSmallFont(16),
        scale = globalScale.get
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

---@param text string
---@param region layout.Region
local function drawTextIn(text, region)
    local x, y, w, h = region:get()
    local sc = globalScale.get()
    w = w * sc
    return love.graphics.printf(text, fonts.getSmallFont(16), x, y, w, "left", 0, sc,sc)
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
    startButton = startButton:shrinkToAspectRatio(3,1)

    local leftBody, rightBody = body:splitHorizontal(2, 1)

    leftBody = leftBody:padRatio(0.1)
    local perkBox, lowerBox = leftBody:splitVertical(1, 2)
    local perkImage, perkDescription = perkBox:splitHorizontal(2, 5)
    perkImage = perkImage:shrinkToAspectRatio(1,1)
    local perkText = perkImage:shrinkToAspectRatio(5,1)
        :attachToTopOf(perkImage)

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.startButton:render(startButton:get())
    self.elements.perkText:render(perkText:get())

    love.graphics.setColor(objects.Color.BLACK)
    drawTextIn("Golden-perk:\nStart the game with 3 extra shop slots", perkDescription)

    drawRegions({
        r,
        body,title,startButton,
        leftBody,rightBody,
        perkBox,lowerBox,
        perkImage,perkText
    })

    love.graphics.setColor(objects.Color.WHITE)
    drawRectangleByConstraint(perkImage)

    drawRectangleByConstraint(rightBody)
end

return NewRunScene
