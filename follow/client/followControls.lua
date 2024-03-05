

input.defineControls({
    "follow:CAMERA_PAN",
    "follow:ZOOM_IN",
    "follow:ZOOM_OUT"
})


input.setControls({
    ["follow:CAMERA_PAN"] = {"key:lshift"},
    ["follow:ZOOM_IN"] = {"scroll:up"},
    ["follow:ZOOM_OUT"] = {"scroll:down"},
})

