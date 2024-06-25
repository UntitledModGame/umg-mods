--- @meta


local ui = {}

---@class Element: ElementClass
ui.Element = require("client.newElement")


---@type table<string, fun(...): Element>)
ui.elements = require("client.elements")

---@class Region: ui.Region
ui.Region = require("kirigami.Region")



umg.expose("ui", ui)
