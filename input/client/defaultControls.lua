
local input = require("client.input")


input.defineControls({
    "input:CLICK_1", -- main click interaction
    "input:CLICK_2", -- opening uis, inspecting stuff, etc
    "input:CLICK_3",

    "input:SCROLL_UP",
    "input:SCROLL_DOWN",
})


input.setControls({
    ["input:CLICK_1"] = {"mouse:1"},
    ["input:CLICK_2"] = {"mouse:2"},
    ["input:CLICK_3"] = {"mouse:3"},

    ["input:SCROLL_UP"] = {"scroll:up"},
    ["input:SCROLL_DOWN"] = {"scroll:down"},
})

