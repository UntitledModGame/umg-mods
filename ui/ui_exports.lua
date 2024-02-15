


-- clientside exports only.
if client then


local ui = require("client.ui")


ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")

ui.Element = require("client.newElement")


function ui.getScreenRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


umg.expose("ui", ui)

end


