
local fonts = require("client.fonts")
local RichText = require("client.elements.RichText")
local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



local loc = localization.localize

---@class lootplot.main.PauseBox: Element
local PauseBox = ui.Element("lootplot.main:PauseBox")

local ARG_KEYS = {
    onResume = true,
    onQuit = true,
    -- setGameSpeed = true
}

function PauseBox:init(args)
    typecheck.assertKeys(args, ARG_KEYS)

    self.background = StretchableBox("white_pressed_big", 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.titleText = RichText({
        font = fonts.getLargeFont(),
        text = loc("Menu")
    })

    self.quitButton = StretchableButton({
        onClick = args.onQuit,
        color = "red",
        text = loc("Quit"),
        scale = 2,
    })
    self.resumeButton = StretchableButton({
        onClick = args.onResume,
        color = "green",
        text = loc("Resume"),
        scale = 2
    })
    self:addChild(self.quitButton)
    self:addChild(self.resumeButton)

    self:addChild(self.background)
    self:addChild(self.titleText)
end


function PauseBox:onRender(x, y, w, h)
    local region = ui.Region(x, y, w, h):padRatio(0.05)
    local titleTextBase, content, buttonBase = region:splitVertical(3, 9, 4)
    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    local buttonContent = buttonBase:padRatio(0.3, 0, 0.3, 0)
    local quitButton, _, resumeButton = buttonContent:splitHorizontal(1, 0.2, 1)

    love.graphics.setColor(objects.Color.WHITE)
    self.background:render(x, y, w, h) -- not region
    self.titleText:render(titleText:get())
    self.quitButton:render(quitButton:get())
    self.resumeButton:render(resumeButton:get())
end

return PauseBox
