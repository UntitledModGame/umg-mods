local fonts = require("client.fonts")

local EndGameBox = require("client.elements.EndGameBox")
local PauseBox = require("client.elements.PauseBox")

local StretchableButton = require("client.elements.StretchableButton")
local ContinueRunDialog = require("client.scenes.ContinueRunDialog")

local DescriptionBox = require("client.DescriptionBox")

---@class lootplot.main.Scene: Element
local Scene = ui.Element("lootplot.main:Screen")

local strings = {
    SPEED_NORM = localization.localize("Speed: Normal"),
    SPEED = localization.newInterpolator("Speed: %{num:.3g}x")
}

function Scene:init()
    self.gameSpeedMultiplerFactor = 0 -- 2^n

    self:makeRoot()
    self:setPassthrough(true)

    self.endGameBox = EndGameBox({
        onDismiss = function()
            self.popupElement = nil
        end
    })

    local SLIDER_SNAP_MULTIPLER = 20
    self.pauseBox = PauseBox({
        onQuit = client.disconnect,
        onResume = function()
            self.popupElement = nil
        end,
        setGameSpeed = function(speed)
            if lp.main.isReady() then
                lp.main.getRun():setSpeedMultipler(2 ^ speed)
            end

            self.gameSpeedMultiplerFactor = speed
        end,

        -- Ideally you should AVOID non-integer value within slider
        -- because it can introduce floating point issue.
        gameSpeedFormatter = function(valueFromSlider)
            local value = math.floor(valueFromSlider) / SLIDER_SNAP_MULTIPLER

            local format
            if value == 0 then
                format = strings.SPEED_NORM
            else
                format = strings.SPEED({num = 2 ^ value})
            end

            return value, format
        end,
        currentGameSpeed = self.gameSpeedMultiplerFactor * SLIDER_SNAP_MULTIPLER,
        gameSpeedRanges = {-2 * SLIDER_SNAP_MULTIPLER, 3 * SLIDER_SNAP_MULTIPLER}
    })

    self.itemDescriptionSelected = nil
    self.itemDescriptionSelectedTime = 0
    self.cursorDescription = nil
    self.cursorDescriptionTime = 0
    self.slotActionButtons = {}
    self.currentSelection = nil

    self.popupElement = nil

    self:addChild(self.endGameBox)
    self:addChild(self.pauseBox)

    self.test = ContinueRunDialog(function()self.test = nil end, function()self.test = nil end)
    self:addChild(self.test)
end


local function drawBoxTransparent(x, y, w, h)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(1, 1, 1)
end

local function drawSideBox(x, y, w, h)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(1, 1, 1)
end

---@param progress number
---@param dbox lootplot.main.DescriptionBox
---@param color objects.Color
---@param region layout.Region
---@param backgroundDrawer fun(x:number,y:number,w:number,h:number)
local function drawDescription(progress, dbox, color, region, backgroundDrawer)
    local x, y, w, h = region:get()
    local bestHeight = select(2, dbox:getBestFitDimensions(w))
    -- local container = layout.Region(0, 0, w, bestHeight)
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


---@param self lootplot.main.Scene
local function isSelectionValid(self)
    local selection = lp.getCurrentSelection()
    if selection and selection == self.currentSelection then
        return true
    end
    return false
end

function Scene:onRender(x,y,w,h)
    local r = layout.Region(x,y,w,h)

    local _, _, right = r:padRatio(0.05):splitHorizontal(2, 5, 2)
    local HEADER_RATIO = 5
    local _, rest2 = right:splitVertical(1, HEADER_RATIO)
    local descriptionOpenSpeed = h * 9

    if not isSelectionValid(self) then
        self:setSelection(nil)
    end

    if self.cursorDescription then
        local mx, my = input.getPointerPosition()
        local descW = w/3
        local descH = select(2, self.cursorDescription:getBestFitDimensions(descW))
        local descRegion = layout.Region(
            math.max(mx - 16 - descW, 16),
            math.min(my + 16, h - descH - 16),
            descW,
            descH
        )
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
            local region = grid[i]:padRatio(0.2)
            button:render(region:get())
        end
    end

    if self.popupElement then
        local dialog = r:padRatio(0.3)
        self.popupElement:render(dialog:get())
    end

    if self.test then
        self.test:render(r:padRatio(0.32, 0.1):get())
    end
end


local function populateDescriptionBox(entity)
    local description = lp.getLongDescription(entity)
    local dbox = DescriptionBox(fonts.getSmallFont(32))

    dbox:addRichText("{wavy}"..text.escapeRichTextSyntax(lp.getEntityName(entity)).."{/wavy}", fonts.getLargeFont(32))
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

---@param self lootplot.main.Scene
---@param selection lootplot.Selected?
local function setSelectedItemDescription(self, selection)
    local itemEnt
    if selection then
        itemEnt = lp.posToItem(selection.ppos)
    end
    if itemEnt then
        self.itemDescriptionSelected = populateDescriptionBox(itemEnt or nil)
    else
        self.itemDescriptionSelected = nil
    end
    self.itemDescriptionSelectedTime = 0
end

local function twiceGlobalScale()
    return globalScale.get()
end

---@param action lootplot.SlotAction
local function createActionButton(action)
    return StretchableButton({
        onClick = function()
            if (action.canClick and action.canClick()) or (not action.canClick) then
                audio.play("lootplot.sound:click", {volume = 0.35, pitch = 1.1})
                action.onClick()
            else
                audio.play("lootplot.sound:deny_click", {volume = 0.5})
            end
        end,
        text = action.text,
        color = action.color or {1,1,1},
        font = fonts.getLargeFont(),
        scale = 2
    })
end


---@param selection lootplot.Selected?
function Scene:setSelection(selection)
    self.currentSelection = selection

    -- Remove existing buttons
    for _, b in ipairs(self.slotActionButtons) do
        self:removeChild(b)
    end
    table.clear(self.slotActionButtons)

    -- Add new buttons
    local actions = selection and selection.actions
    if actions then
        for _, b in ipairs(actions) do
            local button = createActionButton(b)
            self:addChild(button)
            self.slotActionButtons[#self.slotActionButtons+1] = button
        end
    end

    setSelectedItemDescription(self, selection)
end


---@param win boolean
function Scene:showEndGameDialog(win)
    self.endGameBox:setWinning(win)
    self.popupElement = self.endGameBox
end


function Scene:openPauseBox()
    self.popupElement = self.pauseBox
end

return Scene
