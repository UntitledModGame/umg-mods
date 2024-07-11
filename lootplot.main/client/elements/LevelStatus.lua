---@class lootplot.main.LevelStatus: Element
local LevelStatus = ui.Element("lootplot.main:LevelStatus")

local mainBoxColor = objects.Color(love.math.colorFromBytes(224, 224, 224, 224))
local levelNumberBoxColor = objects.Color.WHITE

function LevelStatus:init()

    self.mainBox = ui.elements.SimpleBox({
        color = mainBoxColor,
        rounding = 4,
        thickness = 0.5
    })
    self:addChild(self.mainBox)

    self.levelText = ui.elements.Text({
        text = "Level"
    })
    self:addChild(self.levelText)

    self.levelBox = ui.elements.SimpleBox({
        color = levelNumberBoxColor,
        rounding = 4,
        thickness = 1
    })
    self.levelNumberText = ui.elements.Text({text = "1"})
    self.levelBox:addChild(self.levelNumberText)
    self:addChild(self.levelBox)
end

function LevelStatus:onRender(x,y,w,h)
    local context = lp.main.getContext()
    self.levelNumberText:setText(tostring(context.level))

    local r = ui.Region(x, y, w, h):pad(0.08)
    self.mainBox:render(x, y, w, h)

    local topTextRegion, bottomTextRegion = r:splitVertical(3, 5)
    self.levelText:render(topTextRegion:get())
    local levelNumberRegion = bottomTextRegion:pad(0.1, 0.2, 0.1, 0.1)
    self.levelBox:render(levelNumberRegion:get())
    self.levelNumberText:render(levelNumberRegion:get())
end
