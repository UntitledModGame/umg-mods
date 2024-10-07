local fonts = require("client.fonts")

local lg=love.graphics

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



---@class lootplot.main.NewRunDialog: Element
local NewRunDialog = ui.Element("lootplot.main:NewRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))

---@param newRunAction function
---@param cancelRunAction function?
function NewRunDialog:init(newRunAction, cancelRunAction)
    local e = {}
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
        onClick = newRunAction,
        text = "Start New Run",
        color = objects.Color(1,1,1,1):setHSL(184, 0.7, 0.5),
        font = fonts.getLargeFont(FONT_SIZE),
    })
    if cancelRunAction then
        e.cancelButton = StretchableButton({
            onClick = cancelRunAction,
            text = "Cancel",
            color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
            font = fonts.getLargeFont(FONT_SIZE),
        })
    end
    e.seedLabel = ui.elements.Text({
        text = "Seed:",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color.WHITE,
        font = fonts.getSmallFont(FONT_SIZE),
    })
    e.seedTooltip = ui.elements.Text({
        text = "[Leave empty for random seed]",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color(1, 1, 1, 0.4),
        font = fonts.getSmallFont(FONT_SIZE),
    })
    e.seedInput = ui.elements.Input({
        textColor = objects.Color.WHITE,
        maxLength = 20,
        backgroundColor = objects.Color(1, 1, 1, 0)
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

function NewRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.05, 0.2)

    local title, body, buttonRegion, _ = r:splitVertical(0.1, 0.8, 0.13)
    body = body:padRatio(0.05)
    title = title:padRatio(0.33, 0.1, 0.33, 0.1)
        :moveRatio(0, 0.5 + math.sin(love.timer.getTime())/6)
    local seedBody, modsBody = body:splitVertical(1, 1)
    seedBody = seedBody:padRatio(0, 0.3, 0, 0.3)
    local seedLabel, seedInput = seedBody:splitHorizontal(1, 4)
    local startButton, continueButton
    if self.elements.cancelButton then
        startButton, continueButton = buttonRegion:shrinkToAspectRatio(6,1):splitHorizontal(1,1)
        startButton = startButton:padRatio(0.1,0.25)
        continueButton = continueButton:padRatio(0.1,0.25)
    else
        startButton = buttonRegion:shrinkToAspectRatio(3,1):padRatio(0.1,0.25)
    end

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.seedLabel:render(seedLabel:get())
    if #self.elements.seedInput:getText() == 0 then
        self.elements.seedTooltip:render(seedInput:get())
    end
    self.elements.seedInput:render(seedInput:get())

    self.elements.startButton:render(startButton:get())
    if self.elements.cancelButton then
        self.elements.cancelButton:render(continueButton:get())
    end
end

return NewRunDialog
