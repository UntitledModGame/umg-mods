
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
    RESUME = loc("Resume"),
    MUSIC = loc("Music: "),
    SFX = loc("Sound Effects: ")
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

    do
    local musicVal = math.floor(client.getMusicVolume() * 100)
    self.musicLabel = ui.elements.Text(strings.MUSIC .. tostring(musicVal) .. "%")
    self.musicSlider = Slider({
        onValueChanged = function(_, newVal)
            self.musicLabel:setText(strings.MUSIC .. tostring(math.floor(newVal)) .. "%")
            client.setMusicVolume(newVal / 100)
        end,
        value = musicVal,
        min = 0,
        max = 100
    })
    end

    do
    local sfxVal = math.floor(client.getSFXVolume() * 100)
    self.sfxLabel = ui.elements.Text(strings.SFX .. tostring(sfxVal) .. "%")
    self.sfxSlider = Slider({
        onValueChanged = function(_, newVal)
            self.sfxLabel:setText(strings.SFX .. tostring(math.floor(newVal)) .. "%")
            client.setSFXVolume(newVal / 100)
        end,
        value = sfxVal,
        min = 0,
        max = 100
    })
    end

    self:addChild(self.gameSpeedLabel)
    self:addChild(self.gameSpeedSlider)

    self:addChild(self.musicLabel)
    self:addChild(self.musicSlider)

    self:addChild(self.sfxSlider)
    self:addChild(self.sfxLabel)

    self:addChild(self.quitButton)
    self:addChild(self.resumeButton)

    self:addChild(self.background)
    self:addChild(self.titleText)
end


local function debugRegions(regions)
    for _, r in ipairs(regions) do
        love.graphics.rectangle("line", r:get())
    end
end


function PauseBox:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)

    local region = layout.Region(x, y, w, h):padRatio(0.05)
    self.background:render(x, y, w, h) -- not region

    local titleTextBase, content, buttonBase = region:splitVertical(3, 9, 4)
    content = content:padRatio(0.15)

    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    self.titleText:render(titleText:get())

    local leftSliders, _, rightSliders = content:splitHorizontal(1,0.2, 1)

    local _, gameSpeedSliderBase = leftSliders:splitVertical(1, 2, 1)
    local gameSpeedSliderLabel, gameSpeedSlider = gameSpeedSliderBase:padRatio(0.2):splitVertical(1, 1)
    self.gameSpeedLabel:render(gameSpeedSliderLabel:get())
    self.gameSpeedSlider:render(gameSpeedSlider:get())

    local sfxSliderBase, musicSliderBase = rightSliders:splitVertical(1,1)
    local sfxLabel, sfxSlider = sfxSliderBase:padRatio(0.2):splitVertical(1, 1)
    local musicLabel, musicSlider = musicSliderBase:padRatio(0.2):splitVertical(1, 1)
    self.musicLabel:render(musicLabel:get())
    self.musicSlider:render(musicSlider:get())
    self.sfxSlider:render(sfxSlider:get())
    self.sfxLabel:render(sfxLabel:get())

    local buttonContent = buttonBase:padRatio(0.3, 0, 0.3, 0)
    local quitButton, _, resumeButton = buttonContent:splitHorizontal(1, 0.2, 1)
    self.quitButton:render(quitButton:get())
    self.resumeButton:render(resumeButton:get())

    -- debugRegions({
    --     region, titleText, gameSpeedSliderBase, gameSpeedSliderLabel, content, buttonBase,
    --     quitButton, resumeButton
    -- })
end

return PauseBox
