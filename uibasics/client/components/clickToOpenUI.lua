

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local toggleables = require("client.toggleables")


components.project("clickToOpenUI", "clickable")

local function toggle(ent)
    if ui.basics.isOpen(ent) then
        ui.basics.close(ent)
    else
        -- when opening a chest; we ALSO want to open the player inventory(s)
        toggleables.openAllControlled()
        ui.basics.open(ent)
    end
end

umg.on("clickables:entityClickedClient", function(ent, button, worldX, worldY)
    if ent.clickToOpenUI then
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            toggle(ent)
        end
    end
end)

