

local elements = require("client.elements")

local LUI = require("LUI.init")


local strTc = typecheck.assert("string")

local function newElement(elementName)
    strTc(elementName)
    local elementClass = LUI.Element(elementName)
    elements.defineElement(elementName, elementClass)
    return elementClass
end


return newElement
