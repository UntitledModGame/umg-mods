--- @meta


local ui = {}

ui.Element = require("client.newElement")



--[[
todo: annotate this properly in the future
]]

--- A UI element as part of the LUI library.
---@class Element
local Element = {}

function Element:setup()
end

---@param ent Entity
function Element:bindEntity(ent)
end

---@return Entity?
function Element:getEntity()
end


---@return boolean
function Element:isRoot()
end


--[[
    Denotes this element as a "Root" element.
    This basically tells us that we can draw this element in a detatched fashion.

    (For example, a "Scene" is a good example of a "Root" element)
]]
function Element:makeRoot()
end

--- Pointer events will pass through this element
---@param bool boolean
function Element:setPassthrough(bool)
end




--- Adds a child element to this element's hierarchy.
--- Must be called when using nested elements.
---@param childElem Element
function Element:addChild(childElem)
end


--- Removes a child element from this element's hierarchy.
---@param childElem Element
function Element:removeChild(childElem)
end


---@param childElem Element
---@return boolean
function Element:hasChild(childElem)
end



---@return number,number,number,number
function Element:getView()
end

--- Starts stenciling
---@param x number
---@param y number
---@param w number
---@param h number
function Element:startStencil(x,y,w,h)
end


function Element:endStencil()
end


--- Renders an element
---@param x number
---@param y number
---@param w number
---@param h number
function Element:render(x,y,w,h)
end


--- Call when the pointer moves (mouse)
---@param x number
---@param y number
---@param dx number
---@param dy number
function Element:pointerMoved(x,y, dx, dy)
end


--- Should be called when a control is pressed. will return `true` if the controlEnum should be blocked for other systems; false, otherwise.
---@param controlEnum string
---@return boolean
function Element:controlPressed(controlEnum)
end

--- Should be called when a control is released.
---@param controlEnum string
function Element:controlReleased(controlEnum)
end


---@param text string
function Element:textInput(text)
end


---@param x number
---@param y number
function Element:resize(x,y)
end


---@return Element|false
function Element:getParent()
end


---@return Element[]
function Element:getChildren()
    return self._children
end

---@return Element
function Element:getRoot()
end


--- Gets the parent ent, walking up the elements hierarchy if needed
---@return EntityClass|table<string, any>
function Element:getParentEntity()
end



--- If no args are passed to `:render(x,y,w,h)`,
--- then we will use these 
---@param x number
---@param y number
---@param w number
---@param h number
function Element:setDefaultRegion(x,y,w,h)
end


---@return number,number,number,number
function Element:getDefaultRegion()
end


function Element:focus()
end



function Element:unfocus()
end


--- returns if the element is focused or not
---@return boolean
function Element:isFocused()
end


--- Gets the focused child element
---@return Element
function Element:getFocusedChild()
end


--- Checks whether an element is being hovered by the pointer or not
---@return boolean
function Element:isHovered()
end


--- Checks whether element as active or not. <br>
--- If an element was rendered the previous frame, then its active
---@return boolean
function Element:isActive()
end


--- Returns true if the element is pressed by some control
---@param controlEnum string
---@return boolean
function Element:isPressedBy(controlEnum)
end

--- Checks if the element is clicked
---@return boolean
function Element:isClicked()
end

--- returns true if (x,y) is inside element bounds
---@param x number
---@param y number
---@return boolean
function Element:contains(x,y)
end

--- it gets the element name 
---@return string
function Element:getType()
end






---@type table<string, fun(...): Element>)
ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")



umg.expose("ui", ui)

