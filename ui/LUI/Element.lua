

local util = require("LUI.util")


--[[
todo: annotate this properly in the future
]]

--- A UI element as part of the LUI library.
---@class Element
local Element = {}



local function propagateToActiveChildren(self, funcName, ...)
    for _, child in ipairs(self:getChildren()) do
        if child:isActive() then
            child[funcName](child, ...)
        end
    end
end


local function forcePropagateToChildren(self, funcName, ...)
    for _, child in ipairs(self:getChildren()) do
        child[funcName](child, ...)
    end
end




function Element:setup()
    -- called on initialization
    self._childElementHash = {--[[
        [childElem] -> true
        for checking if we have an elem or not
    ]]}
    self._children = {}

    self._orderedChildren = {}
    -- stack of children elements in order of rendering, per last :render() call.
    -- Useful for mouse-clicks and such.

    self._parent = false
    -- Parent of this element.
    -- Could be a Scene, or a parent Element

    self._defaultRegion = nil

    self._view = {x=0,y=0,w=0,h=0} -- last seen view
    self._active = false
    self._hovered = false
    self._isPressedBy = {--[[
        [controlEnum] -> true/false
        whether this element is being "pressed on" by a controlEnum.
        (Being "pressed-on" means that a control was pressed whilst that element was hovered)
    ]]}

    self._passThrough = false

    self._markedAsRoot = false
    -- if this is set to true, then we will accept this element as a "root".
    -- For example, a `Scene` is regarded as a root element.

    self._focusedChild = false
end





---@return boolean
function Element:isRoot()
    -- element with no parent = root element
    return not self._parent
end


--[[
    Denotes this element as a "Root" element.
    This basically tells us that we can draw this element in a detatched fashion.

    (For example, a "Scene" is a good example of a "Root" element)
]]
function Element:makeRoot()
    self._markedAsRoot = true
end

--- Pointer events will pass through this element
---@param bool boolean
function Element:setPassthrough(bool)
    self._passThrough = bool
end


local function setParent(childElem, parent)
    if parent and childElem:getParent() then
        umg.melt("Element was already contained inside something else!")
    end
    assert(childElem ~= parent, "???")
    childElem._parent = parent
end




local function assertChildElemValid(elem)
   if type(elem) ~= "table" or (not elem.render) then
        umg.melt("not valid LUI element: " .. tostring(elem))
    end
    if elem._markedAsRoot then
        umg.melt("Cannot add an element that is marked as root!")
    end
end


--- Adds a child element to this element's hierarchy.
--- Must be called when using nested elements.
---@param childElem Element
function Element:addChild(childElem)
    if self:hasChild(childElem) then
        return --already has.
    end
    assertChildElemValid(childElem)
    table.insert(self._children, childElem)
    self._childElementHash[childElem] = true
    setParent(childElem, self)
    util.tryCall(self.onAddChild, self)
    return childElem
end


--- Removes a child element from this element's hierarchy.
---@param childElem Element
function Element:removeChild(childElem)
    if not self:hasChild(childElem) then
        return
    end
    childElem:unfocus()
    util.listDelete(self._children, childElem)
    self._childElementHash[childElem] = nil
    setParent(childElem, nil)
    util.tryCall(self.onRemoveChild, self)
end


---@param childElem Element
---@return boolean
function Element:hasChild(childElem)
    return self._childElementHash[childElem]
end




local function setView(self, x,y,w,h)
    -- set the view
    local view = self._view
    view.x = x
    view.y = y
    view.w = w
    view.h = h
end


---@return number,number,number,number
function Element:getView()
    local view = self._view
    return view.x,view.y,view.w,view.h
end


local function deactivateChildren(self)
    self._active = false
    for _, childElem in ipairs(self._children) do
        deactivateChildren(childElem)
    end
end

local function activate(self)
    self._active = true
end


--- Starts stenciling
---@param x number
---@param y number
---@param w number
---@param h number
function Element:startStencil(x,y,w,h)
    love.graphics.setStencilMode("draw", 1)
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setStencilMode("test", 1)
end


function Element:endStencil()
    love.graphics.setStencilMode("off")
end


local function childRendered(self, child)
    if self:hasChild(child) then
        table.insert(self._orderedChildren, child)
    end
end


--- Renders an element
---@param x number
---@param y number
---@param w number
---@param h number
function Element:render(x,y,w,h)
    if self:isRoot() and (not self._markedAsRoot) then
        umg.melt("Attempt to render uncontained element!", 2)
    end

    table.clear(self._orderedChildren)
    local parent = self:getParent()
    if parent then
        childRendered(parent, self)
    end

    deactivateChildren(self)
    activate(self)

    util.tryCall(self.onRender, self, x,y,w,h)
    umg.call("ui:elementRender", self, x,y,w,h)

    setView(self, x,y,w,h)
end



local function getCapturedChild(self, x, y)
    -- returns the child that is "captured" by position (x,y),
    -- (Or nil if there is none.)
    local children = self._orderedChildren
    -- iterate backwards, because last child is the "top" child.
    for i=#children, 1, -1 do
        local child = children[i]
        if child:contains(x, y) and child:isActive() then
            return child
        end
    end
end





local function endHover(self, mx, my)
    if not self._hovered then
        return -- not being hovered
    end
    util.tryCall(self.onEndHover, self, mx, my)
    umg.call("ui:elementEndHover", self, mx,my)
    self._hovered = false
end


local function startHover(self, mx, my)
    if self._hovered then
        return -- already hovered
    end
    util.tryCall(self.onStartHover, self, mx, my)
    umg.call("ui:elementStartHover", self, mx,my)
    self._hovered = true
end

local function updateHover(self, mx, my)
    if self._hovered then
        if not self:contains(mx,my) then
            -- then its no longer hovering!
            endHover(self, mx, my)
        end
    end
end



--- Call when the pointer moves (mouse)
---@param x number
---@param y number
---@param dx number
---@param dy number
function Element:pointerMoved(x,y, dx, dy)
    util.tryCall(self.onPointerMoved, self, x,y, dx,dy)
    umg.call("ui:elementPointerMoved", self, x,y, dx,dy)

    local px,py = input.getPointerPosition()
    updateHover(self, px,py)

    if self:isRoot() and self:contains(px,py) then
        startHover(self, px,py)
    end

    local child = getCapturedChild(self, px,py)
    if child then
        startHover(child, px,py)
    end

    propagateToActiveChildren(self, "pointerMoved", x,y, dx,dy)
end




local function shouldAcceptControl(self, controlEnum)
    -- should we accept `controlEnum`?
    if self.shouldAcceptControl then
        -- 
        -- OVERRIDDABLE:
        -- `shouldAcceptControl` is an overridable method
        --
        return self:shouldAcceptControl(controlEnum)
    end
    -- else; we accept if the element is hovered OR focused.
    return self:isHovered() or self:isFocused()
end



local function propagatePressToChildren(self, controlEnum)
    local consumed = false
    for _, child in ipairs(self:getChildren()) do
        if child:isActive() then
            -- don't want to propagate to child if the controlEnum
            -- has been consumed by another child
            consumed = consumed or child:controlPressed(controlEnum)
        end
    end
    return consumed
end


local function propagateClickToChildren(self, controlEnum, pX, pY)
    local consumed = false
    local child = getCapturedChild(self, pX, pY)
    if child then
        consumed = child:controlClicked(controlEnum, pX, pY)
    end
    return consumed
end



local function dispatchControl(self, controlEnum)
    local consumed = util.tryCall(self.onControlPress, self, controlEnum)
    umg.call("ui:elementControlPressed", self, controlEnum)
    self._isPressedBy[controlEnum] = true
    return consumed
end


--- Should be called when a control is pressed. will return `true` if the controlEnum should be blocked for other systems; false, otherwise.
---@param controlEnum string
---@return boolean
function Element:controlPressed(controlEnum)
    --[[
        this function will return `true` if the controlEnum should be blocked
            for other systems;
        false, otherwise.
    ]]
    if not shouldAcceptControl(self, controlEnum) then
        return false
    end

    local consumed = dispatchControl(self, controlEnum)
    consumed = consumed or propagatePressToChildren(self, controlEnum)
    return consumed
end


function Element:controlClicked(controlEnum, pX, pY)
    --[[
        this function will return `true` if the controlEnum should be blocked
            for other systems;
        false, otherwise.
    ]]
    if not shouldAcceptControl(self, controlEnum) then
        return false
    end

    local consumed = dispatchControl(self, controlEnum)
    consumed = util.tryCall(self.onClick, self, controlEnum) or consumed
    consumed = consumed or propagateClickToChildren(self, controlEnum, pX, pY)
    consumed = consumed or (self:isHovered() and (not self._passThrough))
    return consumed
end

--- Should be called when a control is released.
---@param controlEnum string
function Element:controlReleased(controlEnum)
    -- should be called when mouse is released ANYWHERE in the scene
    if not self._isPressedBy[controlEnum] then
        return -- This event doesn't concern this element
    end
    
    util.tryCall(self.onControlRelease, self, controlEnum)
    umg.call("ui:elementControlReleased", self, controlEnum)
    self._isPressedBy[controlEnum] = nil

    forcePropagateToChildren(self, "controlReleased", controlEnum)
end


---@param text string
function Element:textInput(text)
    util.tryCall(self.onTextInput, self, text)
    propagateToActiveChildren(self, "textInput", text)
end


---@param x number
---@param y number
function Element:resize(x,y)
    util.tryCall(self.onResize, self, x, y)
    forcePropagateToChildren(self, "resize", x, y)
end




---@return Element|false
function Element:getParent()
    return self._parent
end


---@return Element[]
function Element:getChildren()
    return self._children
end


local function maxDepthMelt()
    umg.melt("max depth reached in element heirarchy (Element is a child of itself?)")
end


local MAX_DEPTH = 10000

---@return Element
function Element:getRoot()
    -- gets the root ancestor of this element
    local elem = self
    for _=1,MAX_DEPTH do
        local parent = elem:getParent()
        if parent then
            elem = parent
        else
            return elem -- its the root!
        end
    end
    maxDepthMelt()
end



--- If no args are passed to `:render(x,y,w,h)`,
--- then we will use these 
---@param x number
---@param y number
---@param w number
---@param h number
function Element:setDefaultRegion(x,y,w,h)
    --[[
        if no args are passed to `:render(x,y,w,h)`,
        then we will use these 
    ]]
    self._defaultRegion = self._defaultRegion or {}
    local r = self._defaultRegion
    r.x=x
    r.y=y
    r.w=w
    r.h=h
end


---@return number,number,number,number
function Element:getDefaultRegion()
    local r = self._defaultRegion
    return r.x,r.y, r.w,r.h
end



local function setFocusedChild(self, childElem)
    self._focusedChild = childElem
end


local function tryUnfocusChild(self)
    local child = self._focusedChild
    if child then
        child:unfocus()
    end
end



function Element:focus()
    if self:isFocused() then
        return
    end
    local root = self:getRoot()
    if root then
        -- unfocus existing focused child
        tryUnfocusChild(root)
        setFocusedChild(root, self)
    end

    util.tryCall(self.onFocus, self)
    umg.call("ui:elementFocus", self)
end



function Element:unfocus()
    if not self:isFocused() then
        return
    end

    util.tryCall(self.onUnfocus, self)
    umg.call("ui:elementUnfocus", self)
    local root = self:getRoot()
    if root then
        setFocusedChild(root, nil)
    end
end


--- returns if the element is focused or not
---@return boolean
function Element:isFocused()
    local root = self:getRoot()
    return root:getFocusedChild() == self
end


--- Gets the focused child element
---@return Element
function Element:getFocusedChild()
    return self._focusedChild
end





--- Checks whether an element is being hovered by the pointer or not
---@return boolean
function Element:isHovered()
    return self._hovered
end


--- Checks whether element as active or not. <br>
--- If an element was rendered the previous frame, then its active
---@return boolean
function Element:isActive()
    --[[
        returns whether an element is active or not.

        If an element was :render()ed the previous frame,
        then its active.
    ]]
    return self._active
end




local isPressedByTc = typecheck.assert("control")

--- Returns true if the element is pressed by some control
---@param controlEnum string
---@return boolean
function Element:isPressedBy(controlEnum)
    -- returns true iff the element is clicked on by
    isPressedByTc(controlEnum)
    return self._isPressedBy[controlEnum]
end

--- Checks if the element is clicked
---@return boolean
function Element:isClicked()
    return self:isPressedBy("input:CLICK_PRIMARY")
end



--- returns true if (x,y) is inside element bounds
---@param x number
---@param y number
---@return boolean
function Element:contains(x,y)
    -- returns true if (x,y) is inside element bounds
    local X,Y,W,H = self:getView()
    return  X <= x and x <= (X+W)
        and Y <= y and y <= (Y+H) 
end




--- it gets the element name 
---@return string
function Element:getType()
    -- defined by ElementClass
    return self._elementName
end



return Element
