local fonts = require("client.fonts")
local RichText = require("client.elements.RichText")
local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")

local loc = localization.localize

---@class lootplot.singleplayer.EndGameBox: Element
local EndGameBox = ui.Element("lootplot.singleplayer:EndGameBox")

local strings = {
    OK = loc("OK lol!"),
    WIN_TITLE = loc("{c r=0.35 g=0.9 b=0.38}{wavy amp=2}You Win!!{/wavy}{/c}"),
    WIN_DESC = loc("You win!"),
    LOSE_TITLE = loc("{wavy}{c r=0.9 g=0.3 b=0.1}{u}You Lose :({/u}{/c}"),
    LOSE_DESC = loc("Normally we would quit the game,\nbut since its a playtest, you can keep playing lol.")
}

function EndGameBox:init(args)
    typecheck.assertKeys(args, {"onDismiss"})

    self.background = StretchableBox("white_pressed_big", 8, {
        scale = 2,
        stretchType = "repeat",
        color = objects.Color.BROWN
    })

    self.titleText = RichText({
        font = fonts.getLargeFont()
    })
    self.descriptionText = RichText({
        font = fonts.getSmallFont()
    })

    local RED = {objects.Color.HSLtoRGB(0, 0.61, 0.6)}
    local BLUE = {objects.Color.HSLtoRGB(228, 0.61, 0.6)}
    self.okButtonRed = StretchableButton({
        onClick = args.onDismiss,
        color = RED,
        text = strings.OK,
        scale = 2,
    })
    self.okButtonGreen = StretchableButton({
        onClick = args.onDismiss,
        color = BLUE,
        text = strings.OK,
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
function EndGameBox:setWinning(win)
    self.win = not not win

    if win then
        self.titleText:setText(strings.WIN_TITLE)
        self.descriptionText:setText(strings.WIN_DESC)
    else
        self.titleText:setText(strings.LOSE_TITLE)
        self.descriptionText:setText(strings.LOSE_DESC)
    end
end

local BACKGROUND_COLOR = objects.Color("#FF7A4C30")

function EndGameBox:onRender(x, y, w, h)
    local region = layout.Region(x, y, w, h):padRatio(0.05)
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

return EndGameBox
