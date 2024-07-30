local DescriptionBox = require("client.DescriptionBox")
local CloudBackground = require("client.backgrounds.CloudBackground")
local backgroundManager = require("client.background_manager")

local fonts = require("client.fonts")
local musicManager = require("client.music_manager")

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
    self.itemDescriptionSelected = nil
    self.itemDescriptionSelectedTime = 0
    self.cursorDescription = nil
    self.cursorDescriptionTime = 0
    self.slotActionButtons = {}

    self:addChild(self.pointsBar)
    self:addChild(self.nextRoundButton)
    self:addChild(self.moneyBox)
    self:addChild(self.levelStatus)
end

function Scene:addLootplotElement(element)
    self:addChild(element)
end

local function drawBoxTransparent(x, y, w, h)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(1, 1, 1)
end

local COLOR = {27/255, 27/255, 54/255}
local function drawSideBox(x, y, w, h)
    return ui.elements.SimpleBox.draw(COLOR, x, y, w, h, 10, 4)
end

---@param progress number
---@param dbox lootplot.main.DescriptionBox
---@param color objects.Color
---@param region Region
---@param backgroundDrawer fun(x:number,y:number,w:number,h:number)
local function drawDescription(progress, dbox, color, region, backgroundDrawer)
    local x, y, w, h = region:get()
    local bestHeight = select(2, dbox:getBestFitDimensions(w))
    -- local container = ui.Region(0, 0, w, bestHeight)
    -- local centerContainer = container:center(region)
    local theHeight = math.min(progress, bestHeight)

    backgroundDrawer(x - 5, y - 5, w + 10, theHeight + 10)
    love.graphics.setColor(1, 1, 1)

    if progress >= h then
        love.graphics.setColor(color)
        dbox:draw(x, y, w, h)
        return false
    end

    return true
end

function Scene:onRender(x,y,w,h)
    local context = lp.main.getContext()
    local r = ui.Region(x,y,w,h)

    local left, middle, right = r:pad(0.025):splitHorizontal(2, 5, 2)
    local HEADER_RATIO = 5
    local levelStatusRegion, rest = left:splitVertical(1, HEADER_RATIO)
    local pointsBarRegion = middle:splitVertical(1, HEADER_RATIO)
    local nextRoundRegion, rest2 = right:splitVertical(1, HEADER_RATIO)
    local moneyRegion = rest:splitVertical(1, 4)
    local descriptionOpenSpeed = h * 9

    self.levelStatus:render(levelStatusRegion:get())
    if not context:isDuringRound() then
        self.nextRoundButton:render(nextRoundRegion:get())
    end
    self.pointsBar:render(pointsBarRegion:get())
    self.moneyBox:render(moneyRegion:pad(0, 0.2, 0, 0.2):get())

    local mx, my = input.getPointerPosition()

    if self.cursorDescription then
        local cursorDescRegion = ui.Region(0,0, w/3, h/2)
        local _,_, descW, descH = cursorDescRegion:get()
        local descRegion = ui.Region(mx - 16 - descW, my + 16, descW, descH)
        self.cursorDescriptionTime = self.cursorDescriptionTime + love.timer.getDelta() * descriptionOpenSpeed
        drawDescription(self.cursorDescriptionTime, self.cursorDescription, objects.Color.WHITE, descRegion, drawBoxTransparent)
    end

    if self.itemDescriptionSelected then
        local rightDescRegion = select(2, rest2:splitVertical(1, 5))
        self.itemDescriptionSelectedTime = self.itemDescriptionSelectedTime + love.timer.getDelta() * descriptionOpenSpeed
        drawDescription(self.itemDescriptionSelectedTime, self.itemDescriptionSelected, objects.Color.WHITE, rightDescRegion, drawSideBox)
    end

    if #self.slotActionButtons > 0 then
        local _, bottomArea = r:splitVertical(5, 1)
        _,bottomArea = bottomArea:splitHorizontal(1,3,1)
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

    dbox:addRichText("{wavy}"..text.escape(lp.getEntityName(entity)).."{/wavy}", fonts.getLargeFont(32))
    dbox:newline()

    for _, descriptionText in ipairs(description) do
        dbox:addRichText(descriptionText, fonts.getSmallFont(32))
    end

    return dbox
end

---@param ent lootplot.LayerEntity?
function Scene:setCursorDescription(ent)
    if ent then
        self.cursorDescription = populateDescriptionBox(ent)
    else
        self.cursorDescription = nil
    end
    self.cursorDescriptionTime = 0
end

---@param itemEnt lootplot.ItemEntity?
function Scene:setSelectedItemDescription(itemEnt)
    if itemEnt then
        self.itemDescriptionSelected = populateDescriptionBox(itemEnt)
    else
        self.itemDescriptionSelected = nil
    end
    self.itemDescriptionSelectedTime = 0
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
    scene:setSelectedItemDescription()

    if selection then
        scene:setActionButtons(selection.actions)

        local itemEnt = lp.posToItem(selection.ppos)

        if itemEnt then
            scene:setSelectedItemDescription(itemEnt)
        end
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

local CLOUD_BACKGROUND = CloudBackground()

umg.on("@resize", function(x,y)
    scene:resize(x,y)
    CLOUD_BACKGROUND:resize(x, y)
end)

local SHOW_DESCRIPTION_AFTER = 0.5
local selectedSlot = nil
local slotHoverTime = 0

backgroundManager.setBackground(CLOUD_BACKGROUND)

umg.on("@update", function(dt)
    if selectedSlot then
        if slotHoverTime < SHOW_DESCRIPTION_AFTER then
            slotHoverTime = slotHoverTime + dt

            if slotHoverTime >= SHOW_DESCRIPTION_AFTER then
                local itemEnt = lp.slotToItem(selectedSlot)
                scene:setCursorDescription(itemEnt or selectedSlot)
            end
        end
    end
end)

umg.on("lootplot:startHoverSlot", function(ent)
    selectedSlot = ent
    slotHoverTime = 0
end)

umg.on("lootplot:endHoverSlot", function(ent)
    selectedSlot = nil
    scene:setCursorDescription()
end)

musicManager.playNormalBGM()
