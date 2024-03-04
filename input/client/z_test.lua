


local input = require("client.input")


input.defineControls({
    "A",
    "B",
    "C"
})


input.setControls({
    A = {"key:a", "mouse:1", "mouse:2"},
    B = {"key:a", "key:b"},
    C = {"key:s"}
})


local lis1 = input.InputListener({priority = 5})

lis1:onPress("A", function()
    print("hi")
end)


