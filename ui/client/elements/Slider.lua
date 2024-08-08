
local Slider = ui.Element("ui:Slider")



local Thumb = ui.Element("ui:Thumb")


local function clamp(x, min, max)
    return math.min(max, math.max(min, x))
end




local function getLimitedDelta(elem, mouseX, dx)
    --[[
        This is to ensure that the thumb is moved in-tune with
        the mouse.
    ]]
    local x,_y,w,_h = elem:getView()
    if dx > 0 then
        -- If mouse is behind elem, and we are dragging forward:
        if mouseX < x then
            return 0 -- set delta to 0
        end
    else
        -- If mouse is ahead of elem, and we are dragging back:
        if mouseX > x+w then
            return 0 -- set delta to 0
        end
    end
    return dx
end



local function computeValue(elem, position)
    -- computes value from position
    local mag = elem.max - elem.min
    return elem.min + ((position/elem.totalSize) * mag)
end


local function computePosition(elem, value)
    -- computes position from value
    local mag = elem.max - elem.min
    return ((value - elem.min) / mag) * elem.totalSize
end


function Thumb:onPointerMoved(x,_y, dx, _dy)
    if self:isClicked() then
        local parent = self:getParent()
        dx = getLimitedDelta(self, x, dx)
        parent.position = clamp(parent.position + dx, 0, parent.totalSize)
        parent.value = computeValue(parent, parent.position)
        if parent.onValueChanged then
            parent:onValueChanged(parent.value)
        end
    end
end


local lg = love.graphics

function Thumb:onRender(x,y,w,h)
    lg.rectangle("fill", x,y,w,h)
end







function Slider:init(args)
    typecheck.assertKeys(args, {"onValueChanged", "min", "max"})
    self.onValueChanged = args.onValueChanged
    self.min = args.min
    self.max = args.max
    assert(self.min<=self.max,"wot wot")
    self.value = clamp(0, self.min, self.max)
    self.position = 0

    self.thumb = Thumb()
    self:addChild(self.thumb)
end


local THUMB_RATIO = 4


function Slider:onRender(x,y,w,h)
    local region = ui.Region(x,y,w,h)
    lg.setColor(0.5,0.5,0.5)
    local lineRegion = region:padRatio(0,0.4,0,0.4)
    lg.rectangle("fill",lineRegion:get())
    
    local thumbWidth = w/THUMB_RATIO
    self.totalSize = w - thumbWidth
    self.position = computePosition(self, self.value)
    local thumbRegion = region
        :set(nil,nil,w/THUMB_RATIO,nil)
        :moveUnit(self.position, 0)
        :clampInside(region)
    self.thumb:render(thumbRegion:get())
end


return Slider
