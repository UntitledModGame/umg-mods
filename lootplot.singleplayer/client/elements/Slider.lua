---@class lootplot.singleplayer.Slider: Element
local Slider = ui.Element("lootplot.singleplayer:Slider")

function Slider:init(args)
    typecheck.assertKeys(args, {"onValueChanged", "min", "max"})
    self.onValueChanged = args.onValueChanged
    self.min = args.min
    self.max = args.max
    assert(self.min<=self.max,"wot wot")
    self.value = math.clamp(args.value or 0, self.min, self.max)
    self.valueNormalized = (self.value - self.min) / (self.max - self.min)
    self.lastWidth = 100
    self.lastX = 0

    -- make n9slice
    self.scrollBarSlice = n9slice.new({
        image = client.atlas:getTexture(),
        padding = {4, 3},
        quad = client.assets.images.scrollbar
    })

    self.handleImage = client.assets.images.handle_4
end


function Slider:onPointerMoved(x, y, dx, dy, istouch)
    if self:isClicked() then
        local clampedX = math.clamp(x, self.lastX, self.lastX + self.lastWidth)
        self.valueNormalized = (clampedX - self.lastX) / self.lastWidth
        self.value = (1 - self.valueNormalized) * self.min + self.valueNormalized * self.max
        if self.onValueChanged then
            self:onValueChanged(self.value)
        end
    end
end


local THUMB_RATIO = 4


function Slider:onRender(x,y,w,h)
    self.lastWidth = w
    self.lastX = x

    love.graphics.setColor(objects.Color.WHITE)
    -- FIXME: This slider has **fixed** height!
    local yoff = y + (h - 7 * THUMB_RATIO)
    self.scrollBarSlice:draw(x, yoff, w / THUMB_RATIO, 7, 0, THUMB_RATIO, THUMB_RATIO)

    local handleMaxValue = math.max(w - select(3, self.handleImage:getViewport()) * THUMB_RATIO, 1)
    client.atlas:draw(self.handleImage, x + self.valueNormalized * handleMaxValue, yoff, 0, THUMB_RATIO, THUMB_RATIO)
end


return Slider
