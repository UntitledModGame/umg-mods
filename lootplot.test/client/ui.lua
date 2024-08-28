local testData = require("shared.testData")

---@class lootplot.test.Screen: Element
local Screen = ui.Element("lootplot.test:Screen")

function Screen:init()
    self.testName = "No Test"
end

function Screen:onRender(x, y, w, h)
    local context = testData.getContext()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.testName, x + 4, y + 4)

    if context then
        love.graphics.print("Money: "..context:getMoney(), x + 4, y + 20)
        love.graphics.print("Points: "..context:getPoints(), x + 4, y + 36)
    end

    if testData.isLITReady() then
        love.graphics.printf("Press spacebar to activate random item", x, h - 20, w, "center")
    end
end

---@param name string
function Screen:setTestName(name)
    self.testName = name
end


input.defineControls({"lootplot.test:TriggerLIT"})
input.setControls({
    ["lootplot.test:TriggerLIT"] = {"key:space"},
})

local listener = input.InputListener()
input.add(listener, 0)

listener:onPressed("lootplot.test:TriggerLIT", function(self, controlEnum)
    if testData.isLITReady() then
        testData.triggerLIT()
    end

    self:claim(controlEnum)
end)

local screenInstance = Screen()
testData.setScreenUI(screenInstance)

umg.on("rendering:drawUI", function()
    screenInstance:onRender(love.window.getSafeArea())
end)

umg.on("@draw", -100, function()
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
end)
