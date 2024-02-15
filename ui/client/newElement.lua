

local elements = require("client.elements")

local LUI = require("LUI.init")

local function newElement(elementName)
    local elementClass = LUI.Element(elementName)
    elements.defineElement(elementName, elementClass)
    return elementClass
end


return newElement
