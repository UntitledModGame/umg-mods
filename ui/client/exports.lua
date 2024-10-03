
local ui = {}

ui.elements = require("client.elements")
ui.Region = layout.Region
ui.Element = require("client.newElement")


if false then
    ---Provides user interface functionality.
    ---
    ---Availability: **Client**
    _G.ui = ui
end
umg.expose("ui", ui)
return ui
