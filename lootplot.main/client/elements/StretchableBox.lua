---@class lootplot.main.SimpleBox: Element
local StretchableBox = ui.Element("lootplot.main:StretchableBox")

---@param n9pinst n9p.Instance
function StretchableBox:init(n9pinst)
    self.n9p = n9pinst
    self.content = nil
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
    self.n9p:draw(x, y, w, h)

    if self.content then
        local cx, cy, cw, ch = self.n9p:getContentArea(w, h)
        self.content:render(cx + x, cy + y, cw, ch)
    end
end

return StretchableBox
