


---@class lootplot.main.Scene: Element
local Scene = ui.Element("lootplot.main:Screen")
local BulgeText = require("client.BulgeText")

function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    self.pointsBar = ui.elements.PointsBar({
        getProgress = function()
            local ctx = lp.main.getContext()
            return ctx.requiredPoints-ctx.points, ctx.requiredPoints
        end,
    })
    self.nextRoundButton = ui.elements.NextRoundbutton()
    self.levelStatus = ui.elements.LevelStatus()
    self.moneyBox = ui.elements.MoneyBox()
    ---@type lootplot.DescriptionBox?
    self.itemDescription = nil
    ---@type lootplot.DescriptionBox?
    self.slotDescription = nil

    self:addChild(self.pointsBar)
    self:addChild(self.nextRoundButton)
    self:addChild(self.moneyBox)
    self:addChild(self.levelStatus)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

---@param dbox lootplot.DescriptionBox
---@param region Region
local function drawDescription(dbox, region)
    local x, y, w, h = region:get()
    local bestHeight = select(2, dbox:getBestFitDimensions(w))
    local container = ui.Region(0, 0, w, bestHeight)
    local centerContainer = container:center(region)

    x, y, w, h = centerContainer:get()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x - 5, y - 5, w + 10, h + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)
    dbox:draw(x, y, w, h)
end

function Scene:onRender(x,y,w,h)
    local context = lp.main.getContext()
    local r = ui.Region(x,y,w,h)

    local left, middle, right = r:pad(0.025):splitHorizontal(2, 5, 2)
    local levelStatusRegion, rest = left:splitVertical(1, 4)
    local pointsBarRegion = middle:splitVertical(1, 4)
    local nextRoundRegion, rest2 = right:splitVertical(1, 4)
    local moneyRegion, leftDescRegion = rest:splitVertical(1, 5)

    self.levelStatus:render(levelStatusRegion:get())
    if not context:isDuringRound() then
        self.nextRoundButton:render(nextRoundRegion:get())
    end
    self.pointsBar:render(pointsBarRegion:get())
    self.moneyBox:render(moneyRegion:pad(0, 0.2, 0, 0.2):get())

    if self.itemDescription then
        drawDescription(self.itemDescription, leftDescRegion)
    end
    if self.slotDescription then
        local rightDescRegion = select(2, rest2:splitVertical(1, 5))
        drawDescription(self.slotDescription, rightDescRegion)
    end

    -- local header, lower, main = r:splitVertical(0.2, 0.1, 0.7)
    -- local levelStatus, pointsBar, startRound = header:splitHorizontal(1, 2, 1)

    -- self.levelStatus:render(levelStatus:pad(0.15):get())
    -- self.nextRoundButton:render(startRound:pad(0.15):get())
    -- self.pointsBar:render(pointsBar:get())

    -- local moneyBox,_ = lower:splitHorizontal(0.15, 0.85)
    -- self.moneyBox:render(moneyBox:pad(0.2):get())

    -- local leftDesc, _, rightDesc = main:pad(0.05):splitHorizontal(1, 2, 1)
    -- if self.itemDescription then
    --     drawDescription(self.itemDescription, leftDesc)
    -- end
    -- if self.slotDescription then
    --     drawDescription(self.slotDescription, rightDesc)
    -- end
end

---@param itemEnt lootplot.ItemEntity?
function Scene:setItemDescription(itemEnt)
    if itemEnt then
        self.itemDescription = lp.DescriptionBox()
        self.itemDescription:addText(itemEnt.name or itemEnt:type())
        self.itemDescription:addText(BulgeText(text.escape(itemEnt.description or "No description available")))
        self.itemDescription:newline()
        lp.populateLongDescription(itemEnt, self.itemDescription)
    else
        self.itemDescription = nil
    end
end

---@param slotEnt lootplot.SlotEntity?
function Scene:setSlotDescription(slotEnt)
    if slotEnt then
        self.slotDescription = lp.DescriptionBox()
        self.slotDescription:addText(slotEnt.name or slotEnt:type())
        self.slotDescription:addText(slotEnt.description or "No description available")
        self.slotDescription:newline()
        lp.populateLongDescription(slotEnt, self.slotDescription)
    else
        self.slotDescription = nil
    end
end



---@type lootplot.main.Scene
local scene = Scene()

umg.on("rendering:drawUI", function()
    scene:render(0,0,love.graphics.getDimensions())
end)

local listener = input.InputListener({
    priority = 10
})

listener:onAnyPressed(function(self, controlEnum)
    local consumed = scene:controlPressed(controlEnum)
    if consumed then
        self:claim(controlEnum)
    end
end)

listener:onAnyReleased(function(_self, controlEnum)
    scene:controlReleased(controlEnum)
end)

listener:onTextInput(function(self, txt)
    local captured = scene:textInput(txt)
    if captured then
        self:lockTextInput()
    end
end)

listener:onPointerMoved(function(_self, x,y, dx,dy)
    scene:pointerMoved(x,y, dx,dy)
end)

umg.on("@resize", function(x,y)
    scene:resize(x,y)
end)

umg.on("lootplot:startHoverItem", function(ent)
    scene:setItemDescription(ent)
end)

umg.on("lootplot:startHoverSlot", function(ent)
    scene:setSlotDescription(ent)
end)

umg.on("lootplot:endHoverItem", function(ent)
    scene:setItemDescription(nil)
end)

umg.on("lootplot:endHoverSlot", function(ent)
    scene:setSlotDescription(nil)
end)
