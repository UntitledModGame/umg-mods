local BulgeText = require("client.BulgeText")
local DescriptionBox = require("client.DescriptionBox")

local fonts = require("client.fonts")

---@class lootplot.main.Scene: Element
local Scene = ui.Element("lootplot.main:Screen")

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
    self.itemDescription = nil
    self.itemDescriptionTime = 0
    self.slotDescription = nil
    self.slotDescriptionTime = 0
    self.slotActionButtons = {}

    self:addChild(self.pointsBar)
    self:addChild(self.nextRoundButton)
    self:addChild(self.moneyBox)
    self:addChild(self.levelStatus)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

---@param progress number
---@param dbox lootplot.main.DescriptionBox
---@param region Region
local function drawDescription(progress, dbox, region)
    local x, y, w, h = region:get()
    local bestHeight = select(2, dbox:getBestFitDimensions(w))
    -- local container = ui.Region(0, 0, w, bestHeight)
    -- local centerContainer = container:center(region)
    local theHeight = math.min(progress, bestHeight)

    -- x, y, w, h = container:get()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x - 5, y - 5, w + 10, theHeight + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)

    if progress >= h then
        dbox:draw(x, y, w, h)
        return false
    end

    return true
end

function Scene:onRender(x,y,w,h)
    local context = lp.main.getContext()
    local r = ui.Region(x,y,w,h)

    local left, middle, right = r:pad(0.025):splitHorizontal(2, 5, 2)
    local levelStatusRegion, rest = left:splitVertical(1, 4)
    local pointsBarRegion = middle:splitVertical(1, 4)
    local nextRoundRegion, rest2 = right:splitVertical(1, 4)
    local moneyRegion, leftDescRegion = rest:splitVertical(1, 5)
    local descriptionOpenSpeed = h * 1.5

    self.levelStatus:render(levelStatusRegion:get())
    if not context:isDuringRound() then
        self.nextRoundButton:render(nextRoundRegion:get())
    end
    self.pointsBar:render(pointsBarRegion:get())
    self.moneyBox:render(moneyRegion:pad(0, 0.2, 0, 0.2):get())

    local mx, my = input.getPointerPosition()

    if self.itemDescription then
        local descW, descH = select(2, leftDescRegion:get())
        local descRegion = ui.Region(mx + 16, my + 16, descW, descH)
        self.itemDescriptionTime = self.itemDescriptionTime + love.timer.getDelta() * descriptionOpenSpeed
        if drawDescription(self.itemDescriptionTime, self.itemDescription, descRegion) then
            self.itemDescription:resetRichText()
        end
    end

    if self.slotDescription then
        local rightDescRegion = select(2, rest2:splitVertical(1, 5))
        local descW, descH = select(2, rightDescRegion:get())
        local descRegion = ui.Region(mx - 16 - descW, my + 16, descW, descH)
        self.slotDescriptionTime = self.slotDescriptionTime + love.timer.getDelta() * descriptionOpenSpeed
        if drawDescription(self.slotDescriptionTime, self.slotDescription, descRegion) then
            self.slotDescription:resetRichText()
        end
    end

    if #self.slotActionButtons > 0 then
        local _, bottomArea = r:splitVertical(3, 1)
        local grid = bottomArea:grid(#self.slotActionButtons, 1)

        for i, button in ipairs(self.slotActionButtons) do
            local region = grid[i]:pad(0.1)
            button:render(region:get())
        end
    end
end

local function populateDescriptionBox(entity)
    local description = lp.getLongDescription(entity)
    local dbox = DescriptionBox(fonts.getSmallFont(32))

    dbox:addText(lp.getEntityName(entity), fonts.getLargeFont(32))
    dbox:newline()

    if description:size() == 0 then
        description:add("No description available")
    end

    for _, descriptionText in ipairs(description) do
        if #descriptionText > 0 then
            dbox:addText(BulgeText(text.escape(descriptionText)))
        end
    end

    return dbox
end

---@param itemEnt lootplot.ItemEntity?
function Scene:setItemDescription(itemEnt)
    if itemEnt then
        self.itemDescription = populateDescriptionBox(itemEnt)
    else
        self.itemDescription = nil
    end
    self.itemDescriptionTime = 0
end

---@param slotEnt lootplot.SlotEntity?
function Scene:setSlotDescription(slotEnt)
    if slotEnt then
        self.slotDescription = populateDescriptionBox(slotEnt)
    else
        self.slotDescription = nil
    end
    self.slotDescriptionTime = 0
end

---@param actions lootplot.SlotAction[]?
function Scene:setActionButtons(actions)
    -- Remove existing buttons
    for _, b in ipairs(self.slotActionButtons) do
        self:removeChild(b)
    end

    table.clear(self.slotActionButtons)

    -- Add new buttons
    if actions then
        for _, b in ipairs(actions) do
            local button = ui.elements.ActionButton(b)
            self:addChild(button)
            self.slotActionButtons[#self.slotActionButtons+1] = button
        end
    end
end

---@type lootplot.main.Scene
local scene = Scene()

umg.on("rendering:drawUI", function()
    scene:render(0,0,love.graphics.getDimensions())
end)

-- Handles action button selection
---@param selection lootplot.Selected
umg.on("lootplot:selectionChanged", function(selection)
    if selection then
        scene:setActionButtons(selection.actions)
    else
        scene:setActionButtons()
    end
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

local SHOW_DESCRIPTION_AFTER = 0.5
local selectedItem = nil
local selectedSlot = nil
local itemHoverTime = 0
local slotHoverTime = 0

umg.on("@update", function(dt)
    if selectedItem then
        if itemHoverTime < SHOW_DESCRIPTION_AFTER then
            itemHoverTime = itemHoverTime + dt

            if itemHoverTime >= SHOW_DESCRIPTION_AFTER then
                scene:setItemDescription(selectedItem)
            end
        end
    end

    if selectedSlot then
        if slotHoverTime < SHOW_DESCRIPTION_AFTER then
            slotHoverTime = slotHoverTime + dt

            if slotHoverTime >= SHOW_DESCRIPTION_AFTER then
                scene:setSlotDescription(selectedSlot)
            end
        end
    end
end)

umg.on("lootplot:startHoverItem", function(ent)
    selectedItem = ent
    itemHoverTime = 0
end)

umg.on("lootplot:startHoverSlot", function(ent)
    selectedSlot = ent
    slotHoverTime = 0
end)

umg.on("lootplot:endHoverItem", function(ent)
    selectedItem = nil
    scene:setItemDescription(nil)
end)

umg.on("lootplot:endHoverSlot", function(ent)
    selectedSlot = nil
    scene:setSlotDescription(nil)
end)
