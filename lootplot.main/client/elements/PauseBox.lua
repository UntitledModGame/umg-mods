
local fonts = require("client.fonts")
local RichText = require("client.elements.RichText")
local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



local loc = localization.localize

---@class lootplot.main.PauseBox: Element
local PauseBox = ui.Element("lootplot.main:PauseBox")

function PauseBox:init()
    self.background = StretchableBox("white_pressed_big", 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.titleText = RichText({
        font = fonts.getLargeFont(),
        text = loc("Menu")
    })

    self.quitButton = StretchableButton({
        onClick = function()
            -- TODO: Check that this shuts down the server when clientId is host.
            -- (it SHOULD do... or else BUG!)
            client.disconnect()
        end,
        color = "red",
        text = loc("Quit"),
        scale = 2,
    })
    self:addChild(self.quitButton)

    self:addChild(self.background)
    self:addChild(self.titleText)
end


function PauseBox:onRender(x, y, w, h)
    local region = ui.Region(x, y, w, h):padRatio(0.05)
    local titleTextBase, content, buttonBase = region:splitVertical(3, 9, 4)
    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    local button = buttonBase:padRatio(0.4, 0, 0.4, 0)

    love.graphics.setColor(objects.Color.WHITE)
    self.background:render(x, y, w, h) -- not region
    self.titleText:render(titleText:get())
    self.quitButton:render(button:get())
end

return PauseBox
