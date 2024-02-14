


local ui = {}


ui.Region = require("kirigami.Region")

-- clientside exports only.
if client then

local LUI = require("LUI.init")
ui.LUI = LUI.Element

function ui.getScreenRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end

end


umg.expose("ui", ui)