



local function getGridWH(numElems, W, H)
    for w=1, 1000 do
        local h = math.ceil(numElems / w)

        if (h/w) < (H/W) then
            -- boom! thats our solution (I HOPE)
            return w, h
        end
    end
    error("welp, not gonna search this high")
end



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


function PerkSelect:init()
    self.selectedItem = nil
    self.perkButtons = objects.Array()

    -- used to refresh perks (we dont need to refresh every single frame)
    self.frameCount = 1

    local unlockedPerks = objects.Array()
    local lockedPerks = objects.Array()
    for _, etypeName in ipairs(lp.worldgen.STARTING_ITEMS) do
        local etype = assert(client.entities[etypeName])
        local pb = PerkButton(etype, self)
        if pb.isUnlocked then
            unlockedPerks:add(pb)
        else
            lockedPerks:add(pb)
        end
    end

    -- add unlocked-perks, THEN locked perks
    for _, pb in ipairs(unlockedPerks) do
        self.perkButtons:add(pb)
    end
    for _, pb in ipairs(lockedPerks) do
        self.perkButtons:add(pb)
    end

    for _, elem in ipairs(self.perkButtons) do
        self:addChild(elem)
    end
end


function PerkSelect:getSelectedItem()
    return self.selectedItem
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
    local r = layout.Region(x,y,w,h)
        :padRatio(0.1)

    local gridW, gridH = getGridWH(#self.perkButtons, w, h)
    local gridArr = r:grid(gridW, gridH)

    for i, item in ipairs(self.perkButtons)do
        local r1 = gridArr[i]
        item:render(r1:padRatio(0.2):get())
    end
end



return PerkSelect

