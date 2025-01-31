---Availability: Client and Server
---@class layout
local layout = {}

if false then
    _G.layout = layout
end


layout.Region = require("lib.kirigami.Region")


umg.expose("layout", layout)
return layout
