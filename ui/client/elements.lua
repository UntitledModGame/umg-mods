

local elements = {--[[
    Element registry: 
    Keeps track of all created Element-Types.

    [modname:elementName] = Element-Class
]]}


local function getShortname(name)
    local f = name:find("%:")
    if f then
        return name:sub(f+1, #name)
    end
    return name
end


local defineElementTc = typecheck.assert("string", "table")
function elements.defineElement(elementName, elementClass)
    defineElementTc(elementName, elementClass)
    if elements[elementName] then
        umg.melt("Attempted to redefine an existing element: " .. elementName)
    end

    elements[elementName] = elementClass
    local shortname = getShortname(elementName)
    elements[shortname] = elementClass
end




umg.on("@load", function()
    -- Load all default elements:
    local t = love.filesystem.getDirectoryItems("client/elements")
    assert(t,"?")
    for _, fname in ipairs(t) do
        local noExtension = fname:sub(1,-5) --hacky!
        require("client.elements." .. noExtension)
    end
end)



return elements

