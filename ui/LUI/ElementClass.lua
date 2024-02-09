
local path = (...):gsub('%.[^%.]+$', '')

local Element = require(path .. ".Element")



local function assertParentValid(parent)
    if not parent then
        if parent ~= false then
            error("Element not given parent! (if this is a root element, pass in `nil`)")
        end
        return -- parent=false, therefore its a root element
    end

    if type(parent) ~= "table" or (not parent.render) then
        error("Parent wasn't valid LUI element: " .. tostring(parent))
    end
end


local function initElement(elementClass, parent, ...)
    --[[
        if `parent` is false, then the element is a root element.
        `...` are just arbitrary user arguments passed in.
    ]]
    assertParentValid(parent)
    local element = setmetatable({}, elementClass)
    element:setup(parent)
    if element.init then
        element:init(...)
    end
    return element
end


local function noOverwrite(t,k,v)
    if Element[k] then
        error("Attempted to overwrite builtin method: " .. tostring(k))
    end
    rawset(t,k,v)
end

local ElementClass_mt = {
    __call = initElement,
    __index = Element,
    __newindex = noOverwrite
}


local function newElementClass()
    --[[
        two layers of __index here;
        when we do `element:myMethod()`,

        one __index to `elementClass`, (user-defined element,)
        then, __index to `Element`
    ]]
    local elementClass = {}
    elementClass.__index = elementClass
    setmetatable(elementClass, ElementClass_mt)

    return elementClass
end


return newElementClass

