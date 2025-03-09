
local NUM_PER_LINE = 4


---@class lootplot.singleplayer.PerkButton: Element
local PerkButton = ui.Element("lootplot.singleplayer:_PerkButton")

function PerkButton:init(etype, perkSelect)
    self.etype = etype
    self.perkSelect = perkSelect

    self:refreshUnlock()
end


function PerkButton:refreshUnlock()
    self.isUnlocked = lp.metaprogression.isEntityTypeUnlocked(self.etype)

    if self.isUnlocked then
        self.image = self.etype.image or client.assets.images.unknown_starter_item
    else
        self.image = "locked_starter_item"
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




---@class lootplot.singleplayer.PerkSelect: Element
local PerkSelect = ui.Element("lootplot.singleplayer:PerkSelect")

local MODNAME_ORDER = {
    ["lootplot.singleplayer"] = -1
}

function PerkSelect:init()
    self.selectedItem = nil
    self.perkButtons = objects.Array()

    -- used to refresh perks (we dont need to refresh every single frame)
    self.frameCount = 1

    for _, etypeName in ipairs(lp.worldgen.STARTING_ITEMS) do
        local etype = assert(client.entities[etypeName])
        self.perkButtons:add(PerkButton(etype, self))
    end
    self.perkButtons:sortInPlace(function(a, b)
        local am, an = umg.splitNamespacedString(a.etype:getTypename())
        local bm, bn = umg.splitNamespacedString(b.etype:getTypename())
        local aa = a.isUnlocked and 0 or 1
        local bb = b.isUnlocked and 0 or 1

        if aa == bb then
            local ao = MODNAME_ORDER[am] or 0
            local bo = MODNAME_ORDER[bm] or 0
            if ao == bo then
                return an < bn
            end

            return ao < bo
        end

        return aa < bb
    end)
    for _, elem in ipairs(self.perkButtons) do
        self:addChild(elem)
    end
end


function PerkSelect:getSelectedItem()
    return self.selectedItem
end


function PerkSelect:getHeight(w, h)
    local itemSize = (w / NUM_PER_LINE)
    local itemLines = math.floor(self.perkButtons:size() / NUM_PER_LINE)
    return itemSize * itemLines
end


function PerkSelect:onUpdate()
    self.frameCount = self.frameCount + 1
    if self.frameCount % 60 == 0 then
        for _,pb in ipairs(self.perkButtons) do
            pb:refreshUnlock()
        end
    end
end


function PerkSelect:onRender(x,y,w,h)
    local n = math.floor(self.perkButtons:size()/NUM_PER_LINE) + 1
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

    for i, item in ipairs(self.perkButtons)do
        local r = gridArr[i]
        item:render(r:padRatio(0.2):get())
    end
end



return PerkSelect

