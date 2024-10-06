local globalScale = require("client.globalScale")

---@class lootplot.main.StretchableBox: Element
local StretchableBox = ui.Element("lootplot.main:StretchableBox")


---@param quadName string
---@param padding number[]|number
---@param args? {stretchType?: n9slice.StretchType, content?: any, color:objects.Color}
function StretchableBox:init(quadName, padding, args)
    args = args or {}

    self.content = nil

    local quad = client.assets.images[quadName]
    assert(quad, "?")
    self.n9p = n9slice.new({
        image = client.atlas:getTexture(),
        quad = quad,
        padding = padding,
        stretchType = args.stretchType
    })

    self.color = args.color
    if args.content then
        self:setContent(args.content)
    end
end

if false then
    ---@param quadName string
    ---@param padding number[]|number
    ---@param args? {stretchType?: n9slice.StretchType, content?: any}
    ---@return lootplot.main.StretchableBox
    function StretchableBox(quadName, padding, args) end
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

function StretchableBox:getContent()
    return self.content
end

function StretchableBox:onRender(x, y, w, h)
    love.graphics.push("all")
    if self.color then
        love.graphics.setColor(self.color)
    end
    local scale = globalScale.get()
    local width, height = w / scale, h / scale
    self.n9p:draw(x, y, width, height, 0, scale, scale)

    if self.content then
        local cx, cy, cw, ch = self.n9p:getContentArea(width, height)
        self.content:render(
            cx * scale + x,
            cy * scale + y,
            cw * scale,
            ch * scale
        )
    end
    love.graphics.pop()
end

return StretchableBox
