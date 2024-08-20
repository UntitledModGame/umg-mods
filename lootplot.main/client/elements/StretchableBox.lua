---@class lootplot.main.StretchableBox: Element
local StretchableBox = ui.Element("lootplot.main:StretchableBox")

---@param n9pinst n9p.Instance
function StretchableBox:init(n9pinst, args)
    self.n9p = n9pinst
    self.scale = 1
    self.content = nil

    if args then
        self.scale = args.scale or self.scale
        if args.content then
            self:setContent(args.content)
        end
    end
end

function StretchableBox:setN9P(n9pinst)
    assert(n9pinst)
    self.n9p = n9pinst
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
