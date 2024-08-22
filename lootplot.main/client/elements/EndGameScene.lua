local fonts = require("client.fonts")
local RichText = require("client.elements.RichText")
local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")

local loc = localization.localize

---@class lootplot.main.EndGameScene: Element
local EndGameScene = ui.Element("lootplot.main:EndGameScene")

function EndGameScene:init(args)
    typecheck.assertKeys(args, {"onDismiss"})

    self.background = StretchableBox("orange_pressed_big", 8, {
        scale = 2,
        stretchType = "repeat",
    })

    self.titleText = RichText({
        font = fonts.getLargeFont()
    })
    self.descriptionText = RichText({
        font = fonts.getSmallFont()
    })

    self.okButtonRed = StretchableButton({
        onClick = args.onDismiss,
        color = "red",
        text = loc("Ok!"),
        scale = 2,
    })
    self.okButtonGreen = StretchableButton({
        onClick = args.onDismiss,
        color = "green",
        text = loc("Ok!"),
        scale = 2,
    })

    self:addChild(self.okButtonRed)
    self:addChild(self.okButtonGreen)

    self:addChild(self.background)
    self:addChild(self.titleText)
    self:addChild(self.descriptionText)

    self:setWinning(false)
end

---@param win boolean
function EndGameScene:setWinning(win)
    self.win = not not win

    if win then
        self.titleText:setText(loc("{c r=0.35 g=0.9 b=0.38}{wavy amp=2}You Win!!{/wavy}{/c}"))
        self.descriptionText:setText(loc("You just won the game :coolbear:"))
    else
        self.titleText:setText(loc("{c r=0.9 g=0.3 b=0.1}{u}You Lose :({/u}{/c}"))
        self.descriptionText:setText(loc("You lose the game :pensivebear:"))
    end
end

local BACKGROUND_COLOR = objects.Color("#FF7A4C30")

function EndGameScene:onRender(x, y, w, h)
    local region = ui.Region(x, y, w, h):padRatio(0.05)
    local titleTextBase, content, buttonBase = region:splitVertical(3, 9, 4)
    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    local button = buttonBase:padRatio(0.4, 0, 0.4, 0)

    love.graphics.setColor(objects.Color.WHITE)
    self.background:render(x, y, w, h) -- not region
    self.titleText:render(titleText:get())
    self.descriptionText:render(content:get())

    if self.win then
        self.okButtonGreen:render(button:get())
    else
        self.okButtonRed:render(button:get())
    end
end

return EndGameScene
