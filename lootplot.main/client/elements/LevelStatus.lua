local fonts = require("client.fonts")
local SimpleBox = require("client.elements.SimpleBox")

---@class lootplot.main.LevelStatus: Element
local LevelStatus = ui.Element("lootplot.main:LevelStatus")

local mainBoxColor = objects.Color(love.math.colorFromBytes(224, 224, 224, 224))
local levelNumberBoxColor = objects.Color.WHITE

function LevelStatus:init()

    self.mainBox = SimpleBox({
        color = mainBoxColor,
        rounding = 4,
        thickness = 0.5
    })
    self:addChild(self.mainBox)

    self.levelText = ui.elements.Text({
        text = "Level",
        font = fonts.getLargeFont()
    })
    self:addChild(self.levelText)

    self.levelBox = SimpleBox({
        color = levelNumberBoxColor,
        rounding = 4,
        thickness = 1
    })
    self.levelNumberText = ui.elements.Text({
        text = "1",
        font = fonts.getLargeFont(),
        color = objects.Color.BLACK
    })
    self.currentLevel = 1
    self.levelBox:addChild(self.levelNumberText)
    self:addChild(self.levelBox)
end

if false then
    ---@return lootplot.main.LevelStatus
    function LevelStatus() end
end

function LevelStatus:onRender(x,y,w,h)
    local context = lp.main.getContext()
    if self.currentLevel ~= context.level then
        self.levelNumberText:setText(tostring(context.level))
        self.currentLevel = context.level
    end

    local r = ui.Region(x, y, w, h):padRatio(0.08)
    self.mainBox:render(x, y, w, h)

    local topTextRegion, bottomTextRegion = r:splitVertical(3, 5)
    self.levelText:render(topTextRegion:get())
    local levelNumberRegion = bottomTextRegion:padRatio(0.2, 0.4, 0.2, 0.2)
    self.levelBox:render(levelNumberRegion:get())
    self.levelNumberText:render(levelNumberRegion:get())
end

return LevelStatus
