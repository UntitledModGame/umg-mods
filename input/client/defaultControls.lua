
local input = require("client.input")


input.defineControls({
    "input:CLICK_1", -- main click interaction
    "input:CLICK_2", -- opening uis, inspecting stuff, etc
    "input:CLICK_3"
})


input.setControls({
    ["input:CLICK_1"] = {"mouse:1"},
    ["input:CLICK_2"] = {"mouse:2"},
    ["input:CLICK_3"] = {"mouse:3"}
})

