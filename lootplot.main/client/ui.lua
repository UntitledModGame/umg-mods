



local Scene = ui.Element("lootplot.main:Screen")

function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    self.monsterBar = ui.elements.MonsterBar({
        getProgress = function()
            local ctx = lp.main.getContext()
            return math.clamp(ctx.points / ctx.requiredPoints, 0,1)
        end
    })
    self.nextRoundButton = ui.elements.NextRoundbutton()
    self:addChild(self.monsterBar)
    self:addChild(self.nextRoundButton)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

function Scene:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)

    local header, _main = r:splitVertical(0.15, 0.85)
    local startRound, _, monsterBar = header:splitHorizontal(0.2, 0.05, 0.8)

    self.nextRoundButton:render(startRound:get())
    self.monsterBar:render(monsterBar:get())
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
