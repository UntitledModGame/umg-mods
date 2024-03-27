

local util = require("LUI.util")


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



function Element:getParent()
    return self._parent
end



function Element:setup()
    -- called on initialization
    self._childElementHash = {--[[
        [childElem] -> true
        for checking if we have an elem or not
    ]]}
    self._children = {}

    self._parent = false
    -- Parent of this element.
    -- Could be a Scene, or a parent Element

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

    self._entity = false -- the entity that is bound to this element
end



local bindTc = typecheck.assert("table", "entity")
function Element:bindEntity(ent)
    bindTc(self, ent)
    self._entity = ent
end

function Element:getEntity()
    local e = self._entity
    if umg.exists(e) then
        return e
    end
end




function Element:isRoot()
    -- element with no parent = root element
    return not self._parent
end


function Element:makeRoot()
    --[[
        Denotes this element as a "Root" element.
        This basically tells us that we can draw this element in a detatched fashion.

        (For example, a "Scene" is a good example of a "Root" element)
    ]]
    self._markedAsRoot = true
end

function Element:setPassthrough(bool)
    self._passThrough = bool
end


local function setParent(childElem, parent)
    if parent and childElem:getParent() then
        error("Element was already contained inside something else!")
    end
    assert(childElem ~= parent, "???")
    childElem._parent = parent
end




local function assertChildElemValid(elem)
   if type(elem) ~= "table" or (not elem.render) then
        error("not valid LUI element: " .. tostring(elem))
    end
    if elem._markedAsRoot then
        error("Cannot add an element that is marked as root!")
    end
end


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


function Element:getView()
    local view = self._view
    return view.x,view.y,view.w,view.h
end


local function deactivateheirarchy(self)
    self._active = false
    for _, childElem in ipairs(self._children) do
        deactivateheirarchy(childElem)
    end
end

local function activate(self)
    self._active = true
end


function Element:startStencil(x,y,w,h)
    local function stencil()
        love.graphics.rectangle("fill",x,y,w,h)
    end
    love.graphics.stencil(stencil, "replace", 2)
    love.graphics.setStencilTest("greater", 1)
end


function Element:endStencil()
    love.graphics.setStencilTest()
end


function Element:render(x,y,w,h)
    if self:isRoot() and (not self._markedAsRoot) then
        error("Attempt to render uncontained element!", 2)
    end
    deactivateheirarchy(self)
    activate(self)

    util.tryCall(self.onRender, self, x,y,w,h)
    umg.call("ui:elementRender", self, x,y,w,h)

    setView(self, x,y,w,h)
end



local function getCapturedChild(self, x, y)
    -- returns the child that is "captured" by position (x,y),
    -- (Or nil if there is none.)
    local children = self:getChildren()
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



function Element:pointerMoved(dx, dy)
    util.tryCall(self.onPointerMoved, self, dx, dy)
    umg.call("ui:elementPointerMoved", self, dx, dy)

    local px,py = input.getPointerPosition()
    updateHover(self, px,py)

    if self:isRoot() and self:contains(px,py) then
        startHover(self, px,py)
    end

    local child = getCapturedChild(self, px,py)
    if child then
        startHover(child, px,py)
    end

    propagateToActiveChildren(self, "pointerMoved", dx, dy)
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


local clickControls = objects.Enum({
    --[[
    by default, these controls are special; 
        since they are tied directly to the pointer.
    They also will block more aggressively;
    (For example; if you click on a UI element, the click will be blocked, 
    and will not propagate to external systems)
    ]]
    "input:CLICK_PRIMARY",
    "input:CLICK_SECONDARY"
})
for controlEnum, _v in pairs(clickControls) do 
    assert(input.isValidControl(controlEnum))
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


local function dispatchControl(self, controlEnum)
    local consumed
    if clickControls:has(controlEnum) then
        -- it's special!
        if controlEnum == clickControls["input:CLICK_PRIMARY"] then
            util.tryCall(self.onClickPrimary, self)
        elseif controlEnum == clickControls["input:CLICK_SECONDARY"] then
            util.tryCall(self.onClickSecondary, self)
        end
        consumed = not self._passThrough
    else
        consumed = util.tryCall(self.onControlPress, self, controlEnum)
    end

    umg.call("ui:elementControlPressed", self, controlEnum)
    self._isPressedBy[controlEnum] = true
    return consumed
end


function Element:controlPressed(controlEnum)
    --[[
        this function will return `true` is the controlEnum should be blocked
            for other systems;
        false, otherwise.
    ]]
    if not shouldAcceptControl(self, controlEnum) then
        return false
    end

    local consumed = dispatchControl(self, controlEnum)
    consumed = propagatePressToChildren(self, controlEnum) or consumed
    return consumed
end

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


function Element:textInput(text)
    util.tryCall(self.onTextInput, self, text)
    propagateToActiveChildren(self, "textInput", text)
end


function Element:resize(x,y)
    util.tryCall(self.onResize, self, x, y)
    propagateToActiveChildren(self, "resize", x, y)
end




function Element:getParent()
    return self._parent
end


function Element:getChildren()
    return self._children
end


local function maxDepthError()
    error("max depth reached in element heirarchy (Element is a child of itself?)")
end


local MAX_DEPTH = 10000

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
    maxDepthError()
end


function Element:getParentEntity()
    -- Gets the entity that this element "belongs" to.
    -- Walks up the element heirarchy if needed.
    local elem = self
    for _=1,MAX_DEPTH do
        local ent = elem:getEntity()
        if ent then
            return ent
        end
        elem = elem:getParent()
        if not elem then
            -- no entity in heirarchy.
            return nil
        end
    end
    maxDepthError()
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


function Element:isFocused()
    local root = self:getRoot()
    return root:getFocusedChild() == self
end


function Element:getFocusedChild()
    return self._focusedChild
end





function Element:isHovered()
    return self._hovered
end


function Element:isActive()
    --[[
        returns whether an element is active or not.

        If an element was :render()ed the previous frame,
        then its active.
    ]]
    return self._active
end




local isPressedByTc = typecheck.assert("control")
function Element:isPressedBy(controlEnum)
    -- returns true iff the element is clicked on by
    isPressedByTc(controlEnum)
    return self._isPressedBy[controlEnum]
end

-- QOL helper func:
function Element:isClicked()
    return self:isPressedBy("input:CLICK_PRIMARY")
end



function Element:contains(x,y)
    -- returns true if (x,y) is inside element bounds
    local X,Y,W,H = self:getView()
    return  X <= x and x <= (X+W)
        and Y <= y and y <= (Y+H) 
end




function Element:getType()
    -- defined by ElementClass
    return self._elementName
end



return Element
