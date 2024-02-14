

-- clientside exports only.
if client then

local ui = {}


local LUI = require("LUI.init")
ui.LUI = LUI.Element

ui.Region = require("kirigami.Region")

function ui.getScreenRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


umg.expose("ui", ui)

end

