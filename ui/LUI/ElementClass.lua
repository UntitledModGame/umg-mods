

local Element = require("LUI.Element")



local function initElement(elementClass, ...)
    --[[
        if `parent` is false, then the element is a root element.
        `...` are just arbitrary user arguments passed in.
    ]]
    local element = setmetatable({}, elementClass)
    element:setup()
    if element.init then
        element:init(...)
    end
    return element
end


local function noOverwrite(t,k,v)
    if Element[k] then
        umg.melt("Attempted to overwrite builtin method: " .. tostring(k))
    end
    rawset(t,k,v)
end

local ElementClass_mt = {
    __call = initElement,
    __index = Element,
    __newindex = noOverwrite
}


local function newElementClass(elementName)
    --[[
        two layers of __index here;
        when we do `element:myMethod()`,

        one __index to `elementClass`, (user-defined element,)
        then, __index to `Element`
    ]]
    local elementClass = {
        _elementName = elementName
    }

    local tableTc = typecheck.assert("table", "table")
    function elementClass:implement(otherClass)
        tableTc(self, otherClass)
        assert(self == elementClass, "Cannot be called on instances!")
        for k,v in pairs(otherClass) do
            if not self[k] then
                self[k] = v
            end
        end
        return self
    end

    elementClass.__index = elementClass
    setmetatable(elementClass, ElementClass_mt)
    umg.register(elementClass, elementName)

    return elementClass
end


return newElementClass

