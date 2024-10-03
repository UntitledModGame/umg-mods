local layout = {}

if false then
    ---Availability: Client and Server
    _G.layout = layout
end



-- Exports

layout.Region = require("lib.kirigami.Region")
layout.NLay = require("lib.nlay")

-- TODO: Allow sending region/constraint over the network? Do metatable hack + umg.register here?

umg.expose("layout", layout)
return layout
