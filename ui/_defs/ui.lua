---@meta

ui = {}
---@type table<string, fun(...):Element>
ui.elements = require("client.elements")
---@type fun(x?:number,y?:number,w?:number,h?:number):Region
ui.Region = require("kirigami.Region")
---@type fun(name:string):ElementClass
ui.Element = require("client.newElement")

return ui
