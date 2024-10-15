
local NUM_PER_LINE = 4


---@class lootplot.main.PerkSelect: Element
local PerkButton = ui.Element("lootplot.main:_PerkButton")

function PerkButton:init(etype, perkSelect)
    self.image = etype.image or client.assets.images.unknown_starter_item
    if lp.metaprogression.isEntityTypeUnlocked(etype) then
        
    end
    self.perkSelect = perkSelect
end

function PerkButton:onRender(x,y,w,h)
    ui.drawImageInBox(self.image, x,y,w,h)
end




---@class lootplot.main.PerkSelect: Element
local PerkSelect = ui.Element("lootplot.main:PerkSelect")


function PerkSelect:init()
    self.selectedItem = nil
    self.starterItems = objects.Array()

    for _, etype in ipairs(lp.worldgen.STARTING_ITEMS:getEntries()) do
        if lp.metaprogression.isEntityTypeUnlocked(etype) then
            self.starterItems:add(PerkButton(etype, self))
        end
    end
    self.starterItems:sortInPlace(function (a, b)
        
    end)
    for _, elem in ipairs(self.starterItems) do
        self:addChild(elem)
    end
end


function PerkSelect:getSelectedItem()
    return self.selectedItem
end


function PerkSelect:getHeight(w, h)
    local itemSize = (w / NUM_PER_LINE)
    local itemLines = math.floor(self.starterItems:size() / NUM_PER_LINE)
    return itemSize * itemLines
end


function PerkSelect:onRender(x,y,w,h)
    local n = math.floor(self.starterItems:size()/4) + 1
    local grid = layout.Region(x,y,w,h)
        :padRatio(0.1)
        :grid(n, 4)

    for i, item in ipairs(self.starterItems)do
        local r = grid[i]
        
    end
end


function PerkSelect:onWheelMoved(_,dy)
end


return PerkSelect

