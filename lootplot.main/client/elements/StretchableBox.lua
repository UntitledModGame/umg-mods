---@class lootplot.main.StretchableBox: Element
local StretchableBox = ui.Element("lootplot.main:StretchableBox")


---@param quadName string
---@param cornerWidth number
---@param cornerHeight number
---@param args? {stretchType?: n9slice.StretchType, content?: any, scale?:number}
function StretchableBox:init(quadName, cornerWidth, cornerHeight, args)
    args = args or {}

    self.scale = 1
    self.content = nil

    local quad = client.assets.images[quadName]
    assert(quad, "?")
    self.n9p = n9slice.new({
        image = client.atlas:getTexture(),
        quad = quad,
        cornerWidth = cornerWidth,
        cornerHeight = cornerHeight,
        stretchType = args.stretchType
    })

    self.scale = args.scale or self.scale
    if args.content then
        self:setContent(args.content)
    end
end



---@param content Element?
function StretchableBox:setContent(content)
    if self.content then
        self:removeChild(self.content)
    end

    self.content = content

    if self.content then
        self:addChild(self.content)
    end
end

function StretchableBox:onRender(x, y, w, h)
    local width, height = w / self.scale, h / self.scale
    self.n9p:draw(x, y, width, height, 0, self.scale, self.scale)

    if self.content then
        local cx, cy, cw, ch = self.n9p:getContentArea(width, height)
        self.content:render(
            cx * self.scale + x,
            cy * self.scale + y,
            cw * self.scale,
            ch * self.scale
        )
    end
end

return StretchableBox
