
local input = require("client.input")


input.defineControls({
    "CLICK_A", -- main click interaction
    "CLICK_B", -- opening uis, inspecting stuff, etc
    "CLICK_C"
})


input.setControls({
    CLICK_A = {"mouse:1"},
    CLICK_B = {"mouse:2"},
    CLICK_C = {"mouse:3"}
})

