



local Scene = ui.Element("lootplot.main:Screen")

function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    self.progressBar = ui.elements.LootplotMonsterBar({
        getProgress = function()
            return math.clamp(self.points / self.requiredPoints, 0,1)
        end
    })
    self.startButton = ui.elements.Button({
        text = "nextRound",
        onClick = function()
            lp.getGame():nextRound()
        end
    })
    self:addChild(self.progressBar)
    self:addChild(self.startButton)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

function Scene:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)

    local header, _main = r:splitVertical(0.15, 0.85)
    local startRound, _, progressBar = header:splitHorizontal(0.2, 0.05, 0.8)

    self.startButton:render(startRound:get())
    self.progressBar:render(progressBar:get())
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



return scene


