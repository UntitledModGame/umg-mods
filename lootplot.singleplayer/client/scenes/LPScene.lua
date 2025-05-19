
local loc = localization.localize

local fonts = require("client.fonts")

local PauseBox = require("client.elements.PauseBox")
local StretchableButton = require("client.elements.StretchableButton")
local DescriptionBox = require("client.DescriptionBox")

local settingManager = require("shared.setting_manager")

---@class lootplot.singleplayer.Scene: Element
local Scene = ui.Element("lootplot.singleplayer:Screen")

local strings = {
    SPEED_NORM = localization.localize("Game Speed: Normal"),
    SPEED = localization.newInterpolator("Game Speed: %{num:.3g}x")
}


local SKIP_TEXT = loc("End Early")
local SKIP_TIME_THRESHOLD = 15 -- allow skip after its been running for X seconds



---@param value number
---@param nsig integer
---@return string
local function showNSignificant(value, nsig)
	local zeros = math.floor(math.log10(math.max(math.abs(value), 1)))
	local mulby = 10 ^ math.max(nsig - zeros, 0)
	return tostring(math.floor(value * mulby) / mulby)
end

---@param lpState lootplot.singleplayer.LPState
function Scene:init(lpState)
    self.lpState = assert(lpState)

    self:makeRoot()
    self:setPassthrough(true)

    self.quitButton = nil

    local SLIDER_SNAP_MULTIPLER = 20
    self.pauseBox = PauseBox({
        onQuit = function()
            self.lpState:quitGame()
        end,
        onResume = function()
            self.popupElement = nil
        end,
        setGameSpeed = settingManager.setSpeedFactor,

        -- Ideally you should AVOID non-integer value within slider
        -- because it can introduce floating point issue.
        gameSpeedFormatter = function(valueFromSlider)
            local value = math.floor(valueFromSlider) / SLIDER_SNAP_MULTIPLER

            local format
            local numfmt = showNSignificant(2 ^ value, value < 0 and 2 or 1)
            if numfmt == "1" then
                format = strings.SPEED_NORM
            else
                format = strings.SPEED({num = numfmt})
            end

            return value, format
        end,
        currentGameSpeed = settingManager.getSpeedFactor() * SLIDER_SNAP_MULTIPLER,
        gameSpeedRanges = {-2 * SLIDER_SNAP_MULTIPLER, 4 * SLIDER_SNAP_MULTIPLER}
    })

    self.itemDescriptionSelected = nil
    self.cursorDescription = nil
    self.slotActionButtons = {}
    self.currentSelection = nil

    self.popupElement = nil

    -- skipButton is used IFF the pipeline has been running for too long.
    -- (Some of the players were waiting like 4 hours for their shit to complete lmao)
    self.skipButton = StretchableButton({
        onClick = function()
            lp.singleplayer.clearPipeline()
        end,
        text = SKIP_TEXT,
        color = objects.Color.DARK_RED,
        font = fonts.getLargeFont(),
        scale = 2
    })
    self:addChild(self.skipButton)

    self:addChild(self.pauseBox)
end



---@param self lootplot.singleplayer.Scene
local function isSelectionValid(self)
    local selection = lp.getCurrentSelection()
    if selection and selection == self.currentSelection then
        return true
    end
    return false
end

function Scene:onRender(x,y,w,h)
    local r = layout.Region(x,y,w,h)

    local _, right = r:padRatio(0.05):splitHorizontal(2, 1)
    local HEADER_RATIO = 5
    local _, rest2 = right:splitVertical(1, HEADER_RATIO)

    if not isSelectionValid(self) then
        self:setSelection(nil)
    end

    local run = lp.singleplayer.getRun()
    local plot = run and run:getPlot()
    local allowPipelineSkip = plot and (plot:getPipelineRunningTime() > SKIP_TIME_THRESHOLD)

    if self.quitButton then
        local _, bottomArea = r:splitVertical(5, 1)
        local _,buttonArea,_ = bottomArea:splitHorizontal(1,1,1)
        self.quitButton:render(buttonArea:padRatio(0.2):get())
    elseif allowPipelineSkip then
        local _, bottomArea = r:splitVertical(5, 1)
        local _,buttonArea,_ = bottomArea:splitHorizontal(1,1,1)
        self.skipButton:render(buttonArea:padRatio(0.3):get())
    else
        -- draw action-buttons:
        local buttonCount = #self.slotActionButtons
        if buttonCount > 0 then
            local _, bottomArea = r:splitVertical(5, 1)
            if buttonCount == 1 then
                _,bottomArea = bottomArea:splitHorizontal(1,1,1)
            else
                _,bottomArea = bottomArea:splitHorizontal(1,3,1)
            end
            local grid = bottomArea:grid(#self.slotActionButtons, 1)

            for i, button in ipairs(self.slotActionButtons) do
                local region = grid[i]:padRatio(0.2)
                button:render(region:get())
            end
        end
    end

    if self.cursorDescription then
        local mx, my = input.getPointerPosition()
        local idealDescW = w/3
        local bestDescW, descH = self.cursorDescription:getBestFitDimensions(idealDescW)
        local descW = math.min(idealDescW, bestDescW)
        local descRegion = layout.Region(
            math.max(mx - 16 - descW, 16),
            math.min(my + 16, h - descH - 16),
            descW,
            descH
        )
        self.cursorDescription:draw(descRegion:get())
    end

    if self.itemDescriptionSelected then
        local _, rightDescRegion = rest2:splitVertical(1, 5)
        self.itemDescriptionSelected:draw(rightDescRegion:get())
    end

    if self.popupElement then
        local dialog = r:padRatio(0.3)
        self.popupElement:render(dialog:get())
    end
end



local function populateDescriptionBox(ent)
    local description = lp.getLongDescription(ent)
    local dbox = DescriptionBox(fonts.getSmallFont(32))
    if lp.rarities and ent.rarity then
        -- HACK: dipping into rarities mod, even tho we dont have it as a dependency
        dbox:setBorderColor(ent.rarity.color)
    end

    local title = "{wavy}"..lp.getEntityName(ent).." {/wavy}"

    dbox:addRichText(title, fonts.getLargeFont(32))

    for _, descriptionText in ipairs(description) do
        if type(descriptionText) == "string" and descriptionText:sub(1,3) == "---" then
            dbox:addSeparator()
        else
            dbox:addRichText(descriptionText, fonts.getSmallFont(32))
        end
    end

    local descTags = lp.getDescriptionTags(ent)
    local txt = table.concat(descTags, ", ")
    dbox:addRichText(txt)

    return dbox
end

---@param ent lootplot.LayerEntity?
function Scene:setCursorDescription(ent)
    if ent then
        self.cursorDescription = populateDescriptionBox(ent)
        self.cursorDescription:startOpen()
    else
        self.cursorDescription = nil
    end
end

---@param self lootplot.singleplayer.Scene
---@param selection lootplot.Selected?
local function setSelectedItemDescription(self, selection)
    local itemEnt
    if selection then
        itemEnt = lp.posToItem(selection.ppos)
    end
    if itemEnt then
        self.itemDescriptionSelected = populateDescriptionBox(itemEnt)
        self.itemDescriptionSelected:startOpen()
    else
        self.itemDescriptionSelected = nil
    end
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



function Scene:openPauseBox()
    if not self.popupElement then
        self.popupElement = self.pauseBox
    elseif self.popupElement == self.pauseBox then
        self.popupElement = nil
    end
end



---@param self lootplot.singleplayer.Scene
---@param txt string
---@param color? table
local function makeEndGameQuitButton(self, txt, color)
    self.quitButton = StretchableButton({
        onClick = function()
            self.lpState:quitGame()
        end,
        text = txt,
        color = color or objects.Color.DARK_CYAN,
        font = fonts.getLargeFont(),
        scale = 2
    })
    self:addChild(self.quitButton)
end



local WIN_TEXT = loc("Claim Trophy!")
local LOSE_TEXT = loc("Quit")


function Scene:winGame()
    makeEndGameQuitButton(self, WIN_TEXT, objects.Color.DARK_CYAN)
end


function Scene:loseGame()
    makeEndGameQuitButton(self, LOSE_TEXT, objects.Color.DARK_RED)
end


return Scene

