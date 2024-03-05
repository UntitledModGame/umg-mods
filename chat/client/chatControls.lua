

local t = {
    "chat:COMMAND",
    "chat:CHAT",
    "chat:BACKSPACE"
}
input.defineControls(t)

input.setControls({
    ["chat:COMMAND"] = "key:slash",
    ["chat:CHAT"] = "key:return",
    ["chat:BACKSPACE"] = "key:backspace",
})


return {
    BACKSPACE = "chat:BACKSPACE",
    CHAT = "chat:CHAT",
    COMMAND = "chat:COMMAND"
}

