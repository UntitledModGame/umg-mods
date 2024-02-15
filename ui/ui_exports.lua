


-- clientside exports only.
if client then


local ui = require("client.ui")


ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")


local LUI = require("LUI.init")

function ui.Element(elementName)
    local elementClass = LUI.Element(elementName)
    ui.elements.defineElement(elementName, elementClass)
    return elementClass
end


function ui.getScreenRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


umg.expose("ui", ui)

end


