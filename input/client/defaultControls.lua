
local input = require("client.input")


input.defineControls({
    "input:CLICK_PRIMARY", -- main click interaction
    "input:CLICK_SECONDARY", -- opening uis, inspecting stuff, etc
    "input:CLICK_3",

    "input:SCROLL_UP",
    "input:SCROLL_DOWN",
})


input.setControls({
    ["input:CLICK_PRIMARY"] = {"mouse:1"},
    ["input:CLICK_SECONDARY"] = {"mouse:2"},
    ["input:CLICK_3"] = {"mouse:3"},

    ["input:SCROLL_UP"] = {"scroll:up"},
    ["input:SCROLL_DOWN"] = {"scroll:down"},
})

