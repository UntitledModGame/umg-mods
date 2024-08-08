


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
        local region = array[i]:padRatio(0.1)
        button:render(region:get())
    end
end

-- ---@type lootplot.ButtonScene
-- local scene = ButtonScene()

-- umg.on("rendering:drawUI", function()
--     scene:render(0,0,love.graphics.getDimensions())
-- end)

-- local listener = input.InputListener({
--     priority = 10
-- })

-- listener:onAnyPressed(function(self, controlEnum)
--     local consumed = scene:controlPressed(controlEnum)
--     if consumed then
--         self:claim(controlEnum)
--     end
-- end)

-- listener:onAnyReleased(function(_self, controlEnum)
--     scene:controlReleased(controlEnum)
-- end)

-- listener:onTextInput(function(self, txt)
--     local captured = scene:textInput(txt)
--     if captured then
--         self:lockTextInput()
--     end
-- end)

-- listener:onPointerMoved(function(_self, x,y, dx,dy)
--     scene:pointerMoved(x,y, dx,dy)
-- end)

-- umg.on("@resize", function(x,y)
--     scene:resize(x,y)
-- end)

-- return scene
