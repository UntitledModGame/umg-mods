


---@class lootplot.ButtonScene: Element
local ButtonScene = ui.Element("lootplot:Screen")

function ButtonScene:init(args)
    self:makeRoot()
    self:setPassthrough(true)
    self.buttons = objects.Array()
end

---@param buttons objects.Array
function ButtonScene:setButtons(buttons)
    self:clear()

    for _, button in ipairs(buttons) do
        self.buttons:add(button)
        self:addChild(button)
    end
end

function ButtonScene:clear()
    for _, button in ipairs(self.buttons) do
        self:removeChild(button)
    end

    self.buttons:clear()
end

function ButtonScene:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    local _, bot = r:splitVertical(0.7, 0.3)
    local array = bot:grid(self.buttons:size(), 1)

    for i, button in ipairs(self.buttons) do
        local region = array[i]:padRatio(0.2)
        button:render(region:get())
    end
end
