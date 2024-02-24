
local slotService = require("client.slotService")


local SlotElement = ui.Element()


local KEYS = {"slot", "inventory"}

function SlotElement:init(args)
    objects.assertKeys(args, KEYS)
    self.slot = args.slot
    self.inventory = args.inventory

    -- blank image for now
    self.image = ui.elements.Image({})
    self.hasImage = false
end



local function updateImage(self)
    local inv = self.inventory
    local ent = inv:get(self.slot)
    if umg.exists(ent) then
        local img = items.getItemIcon(ent)
        self.hasImage = true
        self.image:setImage(img)
    else
        self.hasImage = false
    end
end


function SlotElement:onRender(x,y,w,h)
    updateImage(self)

    if self.hasImage then
        self.image:render(x,y,w,h)
    end
end



function SlotElement:onMousePress(mx, my, button)
    slotService.interact(self.inventory, self.slot, button)
end



return SlotElement

