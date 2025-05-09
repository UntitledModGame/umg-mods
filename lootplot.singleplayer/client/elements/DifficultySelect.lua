


local fonts = require("client.fonts")
local loc = localization.localize


---@class lootplot.singleplayer.DifficultySelect: Element
---@field newRunScene lootplot.singleplayer.NewRunScene
---@field difficulties objects.Array
---@field selectedIndex number
local DifficultySelect = ui.Element("lootplot.singleplayer:DifficultySelect")


local function canPlayWith(self, index)
    if index == 1 then
        return true
    end
    local starterItemType = self.newRunScene:getSelectedStarterItem()
    local starterItem = starterItemType:getTypename()
    if starterItem and lp.isWinRecipient(starterItem) then
        local difficulty = self.difficulties[index - 1]
        return lp.hasWonOnDifficulty(starterItem, difficulty)
    end
end


---@param self lootplot.singleplayer.DifficultySelect
local function canGoHarder(self)
    if self.selectedIndex >= #self.difficulties then
        return false
    end
    if canPlayWith(self, self.selectedIndex + 1) then
        return true
    end
end



---@param newRunScene lootplot.singleplayer.NewRunScene
function DifficultySelect:init(newRunScene)
    self.newRunScene = newRunScene

    self.difficulties = objects.Array(lp.DIFFICULTY_TYPES)
    self.difficulties:sortInPlace(function(d1, d2)
        return lp.getDifficultyInfo(d1).difficulty < lp.getDifficultyInfo(d2).difficulty
    end)

    self.hardestDiff = 10000000
    self.difficulties:map(function(diffId)
        local dInfo = lp.getDifficultyInfo(diffId)
        self.hardestDiff = math.min(dInfo.difficulty, self.hardestDiff)
    end)

    self.selectedIndex = 1

    self.harderButton = ui.elements.Button({
        click = function()
            if canGoHarder(self) then
                self.selectedIndex = math.min(self.selectedIndex + 1, #self.difficulties)
            end
        end,
        image = client.assets.images.difficulty_up_button
    })
    self:addChild(self.harderButton)

    self.easierButton = ui.elements.Button({
        click = function()
            self.selectedIndex = math.max(1, self.selectedIndex - 1)
        end,
        image = client.assets.images.difficulty_down_button
    })
    self:addChild(self.easierButton)
end


function DifficultySelect:onUpdate()
    -- (emulate a while-loop, i dont trust while-loops)
    for i=1, 100 do
        if not canPlayWith(self, self.selectedIndex) then
            self.selectedIndex = math.max(1, self.selectedIndex - 1)
        else
            break -- its ok, we can play with it
        end
    end
end


---@return string
function DifficultySelect:getSelectedDifficulty()
    return self.difficulties[self.selectedIndex]
end



function DifficultySelect:onRender(x, y, w, h)
    local r = layout.Region(x, y, w, h):padRatio(0.1)

    local rButton, rText, rImg = r:splitHorizontal(1, 2.2, 0.8)

    local startItem = self.newRunScene:getSelectedStarterItem()
    if not startItem then
        return -- no point in rendering.
    end

    local harder, easier = rButton:splitVertical(1,1)
    if canGoHarder(self) then
        self.harderButton:render(harder:padRatio(0.1):get())
    end
    if self.selectedIndex > 1 then
        self.easierButton:render(easier:padRatio(0.1):get())
    end

    local diff = lp.getDifficultyInfo(self:getSelectedDifficulty())
    text.printRichContained(diff.name, fonts.getLargeFont(16), rText:padRatio(0.2):get())

    ui.drawImageInBox(diff.image, rImg:padRatio(0.2):get())
end

return DifficultySelect

