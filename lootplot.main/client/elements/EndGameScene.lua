local fonts = require("client.fonts")
local loc = localization.localize

---@class lootplot.main.EndGameScene: Element
local EndGameScene = ui.Element("lootplot.main:EndGameScene")

function EndGameScene:init(args)
    typecheck.assertKeys(args, {"onDismiss"})

    self.titleText = ui.elements.RichText({
        font = fonts.getLargeFont()
    })
    self.descriptionText = ui.elements.RichText({
        font = fonts.getSmallFont()
    })
    self.okButton = ui.elements.Button({
        onClick = args.onDismiss,
        text = loc("Ok!"),
        backgroundColor = objects.Color("#FFC7FFB7"),
        textColor = objects.Color.BLACK
    })

    self:addChild(self.titleText)
    self:addChild(self.descriptionText)
    self:addChild(self.okButton)
    self:setWinning(false)
end

---@param win boolean
function EndGameScene:setWinning(win)
    self.win = win

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
    local titleTextBase, content, buttonBase = region:splitVertical(2, 7, 1)
    local titleText = titleTextBase:padUnit(0, 0, 0, 8)
    local button = buttonBase:padRatio(0.4, 0, 0.4, 0)

    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.rectangle("fill", x, y, w, h) -- not region
    love.graphics.setColor(objects.Color.WHITE)
    self.titleText:render(titleText:get())
    self.descriptionText:render(content:get())
    self.okButton:render(button:get())
end

return EndGameScene
