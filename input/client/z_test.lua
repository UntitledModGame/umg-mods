


local input = require("client.input")


input.defineControls({
    "A",
    "B",
    "C"
})


input.setControls({
    A = {"key:a"},
    B = {"key:b"},
    C = {"key:s"}
})


local lis1 = input.InputListener({priority = 5})
lis1:onPress("A", function()
    print("press A")
end)
lis1:onRelease("B", function()
    print("release B")
end)


local lis2 = input.InputListener({priority = 10})
local toggled = false
lis2:onUpdate(function(self,dt)
    if toggled and self:isDown("A") then
        print("T:", love.timer.getTime())
        self:claim("A")
    end
end)

lis2:onPress("B", function()
    toggled = not toggled
end)




local lis3 = input.InputListener({priority = 11})
lis3:onUpdate(function(self,dt)
    if toggled and self:isDown("A") then
        if math.floor(love.timer.getTime()) % 2 == 0 then
            print("YUPPITY.")
            self:claim("A")
        end
    end
end)



