


---@class lootplot.main.Scene: Element
local Scene = ui.Element("lootplot.main:Screen")

function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    self.monsterBar = ui.elements.FancyBar({
        getProgress = function()
            local ctx = lp.main.getContext()
            return ctx.points, ctx.requiredPoints
        end,
        text = "Points",
        mainColor = {
            hue = 0,
            saturation = 1
        },
        catchUpColor = {
            hue = 50,
            saturation = 1
        },
        outlineWidth = 0.01,
    })
    self.nextRoundButton = ui.elements.NextRoundbutton()
    self.moneyBox = ui.elements.MoneyBox()

    self:addChild(self.monsterBar)
    self:addChild(self.nextRoundButton)
    self:addChild(self.moneyBox)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

function Scene:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)

    local header, lower, _main = r:splitVertical(0.2, 0.1, 0.7)
    local monsterBar, _, startRound = header:splitHorizontal(0.8, 0.05, 0.2)

    self.nextRoundButton:render(startRound:pad(0.15):get())
    self.monsterBar:render(monsterBar:pad(0.03,0.1,0.03,0.1):get())

    local moneyBox,_ = lower:splitHorizontal(0.15, 0.85)
    self.moneyBox:render(moneyBox:pad(0.2):get())
end








local scene = Scene()

umg.on("rendering:drawUI", function()
    scene:render(0,0,love.graphics.getDimensions())
end)

local listener = input.InputListener({
    priority = 10
})

listener:onAnyPressed(function(self, controlEnum)
    local consumed = scene:controlPressed(controlEnum)
    if consumed then
        self:claim(controlEnum)
    end
end)

listener:onAnyReleased(function(_self, controlEnum)
    scene:controlReleased(controlEnum)
end)

listener:onTextInput(function(self, txt)
    local captured = scene:textInput(txt)
    if captured then
        self:lockTextInput()
    end
end)

listener:onPointerMoved(function(_self, x,y, dx,dy)
    scene:pointerMoved(x,y, dx,dy)
end)

umg.on("@resize", function(x,y)
    scene:resize(x,y)
end)
