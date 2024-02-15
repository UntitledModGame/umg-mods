


-- clientside exports only.
if client then


local ui = require("client.ui")


ui.Region = require("kirigami.Region")


local LUI = require("LUI.init")
ui.LUI = LUI.Element

function ui.getScreenRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


umg.expose("ui", ui)

end


