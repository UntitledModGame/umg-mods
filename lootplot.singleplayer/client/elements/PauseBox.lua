
local fonts = require("client.fonts")
local RichText = require("client.elements.RichText")
local Slider = require("client.elements.Slider")
local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



local loc = localization.localize

---@class lootplot.singleplayer.PauseBox: Element
local PauseBox = ui.Element("lootplot.singleplayer:PauseBox")

local ARG_KEYS = {
    onResume = true,
    onQuit = true,

    setGameSpeed = true,
    currentGameSpeed = true,
    gameSpeedFormatter = true,
    gameSpeedRanges = true,
}

local strings = {
    MENU = loc("Menu"),
    QUIT = loc("Save-Quit"),
    RESUME = loc("Resume")
}

function PauseBox:init(args)
    typecheck.assertKeys(args, ARG_KEYS)

    self.background = StretchableBox("white_pressed_big", 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.titleText = RichText({
        font = fonts.getLargeFont(),
        text = strings.MENU
    })

    local RED = {objects.Color.HSLtoRGB(0, 0.61, 0.6)}
    local BLUE = {objects.Color.HSLtoRGB(228, 0.61, 0.6)}
    self.quitButton = StretchableButton({
        onClick = args.onQuit,
        color = RED,
        text = strings.QUIT,
        scale = 2,
    })
    self.resumeButton = StretchableButton({
        onClick = args.onResume,
        color = BLUE,
        text = strings.RESUME,
        scale = 2
    })

    self.gameSpeedLabel = ui.elements.Text(select(2, args.gameSpeedFormatter(args.currentGameSpeed)))
    self.gameSpeedSlider = Slider({
        onValueChanged = function(_, value)
            local fixedValue, formatString = args.gameSpeedFormatter(value)
            self.gameSpeedLabel:setText(formatString)
            args.setGameSpeed(fixedValue)
        end,
        value = args.currentGameSpeed,
        min = args.gameSpeedRanges[1],
        max = args.gameSpeedRanges[2],
    })

    self:addChild(self.gameSpeedLabel)
    self:addChild(self.gameSpeedSlider)

    self:addChild(self.quitButton)
    self:addChild(self.resumeButton)

    self:addChild(self.background)
    self:addChild(self.titleText)
end


function PauseBox:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)

    local region = layout.Region(x, y, w, h):padRatio(0.05)
    self.background:render(x, y, w, h) -- not region

    local titleTextBase, content, buttonBase = region:splitVertical(3, 9, 4)

    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    self.titleText:render(titleText:get())

    local gameSpeedSliderBase = select(2, content:splitVertical(1, 2, 1))
    local gameSpeedSliderLabel, gameSpeedSlider = gameSpeedSliderBase:splitVertical(1, 1)
    self.gameSpeedLabel:render(gameSpeedSliderLabel:get())
    self.gameSpeedSlider:render(gameSpeedSlider:get())

    local buttonContent = buttonBase:padRatio(0.3, 0, 0.3, 0)
    local quitButton, _, resumeButton = buttonContent:splitHorizontal(1, 0.2, 1)
    self.quitButton:render(quitButton:get())
    self.resumeButton:render(resumeButton:get())
end

return PauseBox
