

--[[

Scene object

Scenes contain elements

]]



local path = (...):gsub('%.[^%.]+$', '')

local util = require(path .. ".util")

local Scene = util.Class()


function Scene:init()
    self.elements = {}
end


function Scene:addElement(rootElem)
    assert(not rootElem:isContained(), "This element is already contained by another Scene, or is a child of another element!")
    assert(rootElem:isRoot(), "Only root elements can be added to scenes")
    table.insert(self.elements, rootElem)
    rootElem:setContained(true)
end



function Scene:removeElement(rootElem)
    util.listDelete(self.elements, rootElem)
    rootElem:setContained(false)
end


function Scene:focus(rootElem)
    util.listDelete(self.elements, rootElem)
    table.insert(self.elements, rootElem)
end


function Scene:hasElement(element)
    return util.find(element)
end




function Scene:render()
    for i=#self.elements, 1, -1 do
        local elem = self.elements[i]
        elem:render(elem:getView())
    end
end


local function getFocused(self)
    local len = #self.elements
    return self.elements[len]
end

local function tryCallFocused(self, method, ...)
    local focused = getFocused(self)
    if focused then
        focused[method](focused, ...)
    end
end

local function callForAll(self, method, ...)
    for i=#self.elements, 1, -1 do
        local elem = self.elements[i]
        elem[method](elem, ...)
    end
end



local FOCUS_BUTTON = 1

function Scene:mousepressed(mx, my, button, istouch, presses)
    for i=#self.elements, 1, -1 do
        local elem = self.elements[i]
        if elem:contains(mx, my) then
            elem:mousepressed(mx, my, button, istouch, presses)
            if button == FOCUS_BUTTON then
                self:focus(elem)
            end
        end
    end
end



function Scene:mousereleased(mx, my, button, istouch)
    callForAll(self, "mousereleased", mx, my, button, istouch)
end

function Scene:mousemoved(mx, my, dx, dy, istouch)
    callForAll(self, "mousemoved", mx, my, dx, dy, istouch)
end

function Scene:keypressed(key, scancode, isrepeat)
    tryCallFocused(self, "keypressed", key, scancode, isrepeat)
end

function Scene:keyreleased(key, scancode)
    tryCallFocused(self, "keyreleased", key, scancode)
end

function Scene:textinput(text)
    tryCallFocused(self, "textinput", text)
end

function Scene:wheelmoved(dx,dy)
    callForAll(self, "wheelmoved", dx, dy)
end

function Scene:resize(x,y)
    callForAll(self, "resize", x,y)
end


return Scene

