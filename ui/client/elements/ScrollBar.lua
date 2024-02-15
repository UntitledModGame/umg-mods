

local ScrollBar = LUI.Element()


local ScrollThumb = LUI.Element()


local function clamp(x, min, max)
    return math.min(max, math.max(min, x))
end



local function getLimitedDelta(elem, mouseY, dy)
    --[[
        This is to ensure that the thumb is moved in-tune with
        the mouse.
    ]]
    local _x,y,_w,h = elem:getView()
    if dy > 0 then
        -- If mouse is behind elem, and we are dragging forward:
        if mouseY < y then
            return 0 -- set delta to 0
        end
    else
        -- If mouse is ahead of elem, and we are dragging back:
        if mouseY > y+h then
            return 0 -- set delta to 0
        end
    end
    return dy
end





local DEFAULT_SENSITIVITY = 5


local SCROLL_BUTTON = 1

function ScrollThumb:onMousePressed(button)
    return button == SCROLL_BUTTON
end

function ScrollThumb:onMouseMoved(x, y, dx, dy, istouch)
    if self:isClickedOnBy(SCROLL_BUTTON) then
        local parent = self:getParent()
        dy = getLimitedDelta(self, y, dy)
        parent.position = clamp(parent.position + dy, 0, parent.totalSize)
    end
end

function ScrollThumb:onRender(x,y,w,h)
    ui.style:rectangle(x,y,w,h)
end



local EMPTY = {}

function ScrollBar:init(args)
    args = args or EMPTY
    self.position = 0
    self.totalSize = 0
    self.sensitivity = args.sensitivity or DEFAULT_SENSITIVITY
    self.thumb = ScrollThumb(self, args)
end


function ScrollBar:scroll(dy)
    local delta = -dy * self.sensitivity
    self.position = clamp(self.position + delta, 0, self.totalSize)
end

function ScrollBar:onWheelMoved(_, dy)
    self:scroll(dy)
    return true
end


function ScrollBar:getScroll()
    return self.position
end

function ScrollBar:getScrollRatio()
    return self.position / self.totalSize
end


local THUMB_RATIO = 5 -- thumb is 5 times smaller than scrollbar

function ScrollBar:onRender(x,y,w,h)
    local region = ui.Region(x,y,w,h)
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.rectangle("line",region:get())
    
    local thumbSize = h/THUMB_RATIO
    self.totalSize = h - thumbSize
    local thumbRegion = region
        :set(nil,nil,nil,thumbSize)
        :offset(0, self.position)
        :clampInside(region)
    self.thumb:render(thumbRegion:get())
end



return ScrollBar
