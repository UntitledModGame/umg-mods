
local NUM_PER_LINE = 4


---@class lootplot.main.PerkSelect: Element
local PerkButton = ui.Element("lootplot.main:_PerkButton")

function PerkButton:init(etype, perkSelect)
    self.etype = etype
    self.perkSelect = perkSelect

    self.isUnlocked = lp.metaprogression.isEntityTypeUnlocked(etype)

    if self.isUnlocked then
        self.image = etype.image or client.assets.images.unknown_starter_item
    else
        self.image = "unknown_starter_item"
    end
end

function PerkButton:onRender(x,y,w,h)
    local pad,xtra = 0,0
    if self:isHovered() then
        xtra = w/4
        pad = w/8
    end
    ui.drawImageInBox(self.image, x-pad,y-pad, w+xtra,h+xtra)
end

function PerkButton:onClick()
    if self.isUnlocked then
        audio.play("lootplot.sound:click", {volume = 0.35, pitch = 0.6})
        self.perkSelect.selectedItem = self.etype
    else
        audio.play("lootplot.sound:deny_click", {volume = 0.5})
    end
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
        local aa = a.isUnlocked and 0 or 1
        local bb = b.isUnlocked and 0 or 1
        return aa < bb
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
    local n = math.floor(self.starterItems:size()/NUM_PER_LINE) + 1
    local gx,gy,gw,gh = layout.Region(x,y,w,h)
        :padRatio(0.1)
        :get()

    local sze=gw/NUM_PER_LINE

    local gridArr = objects.Array()
    for yy=0, n-1 do
        for xx=0,NUM_PER_LINE-1 do
            gridArr:add(layout.Region(
                gx + xx*sze,
                gy + yy*sze,
                sze,
                sze
            ))
        end
    end

    for i, item in ipairs(self.starterItems)do
        local r = gridArr[i]
        item:render(r:padRatio(0.2):get())
    end
end



return PerkSelect

