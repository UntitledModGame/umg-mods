


-- clientside exports only.
if client then



local ui = {}

ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")

ui.Element = require("client.newElement")


umg.expose("ui", ui)

end


