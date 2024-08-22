


-- clientside exports only.
if client then



local ui = {}

---@type ui.elements
ui.elements = require("client.elements")
---@type fun(x?:number,y?:number,w?:number,h?:number):Region
ui.Region = require("kirigami.Region")
---@type fun(name:string):(ElementClass|Element)
ui.Element = require("client.newElement")


umg.expose("ui", ui)

end


