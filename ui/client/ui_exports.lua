





local ui = {}

ui.elements = require("client.elements")
---@type fun(x?:number,y?:number,w?:number,h?:number):ui.Region
ui.Region = require("kirigami.Region")
---@type fun(name:string):(ElementClass|Element)
ui.Element = require("client.newElement")


umg.expose("ui", ui)



