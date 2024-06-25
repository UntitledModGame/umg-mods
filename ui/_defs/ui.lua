--- @meta


local ui = {}

ui.Element = require("client.newElement")

---@type table<string, fun(...): Element>)
ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")



umg.expose("ui", ui)

