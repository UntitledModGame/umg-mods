---Availability: Client and Server
---@class layout
local layout = {}

if false then
    _G.layout = layout
end



-- Exports

layout.Region = require("lib.kirigami.Region")
layout.NLay = require("lib.nlay")

-- TODO: Allow sending region/constraint over the network? Do metatable hack + umg.register here?



if client then

umg.on("@resize", function(w, h)
    return layout.NLay.update(0, 0, w, h)
end)

end -- if client



umg.expose("layout", layout)
return layout
