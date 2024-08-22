local LUI = require("LUI.init")


local strTc = typecheck.assert("string")

---@return Element|ElementClass
local function newElement(elementName)
    strTc(elementName)
    local elementClass = LUI.Element(elementName)
    return elementClass
end


return newElement
