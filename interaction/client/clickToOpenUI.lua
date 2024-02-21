

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local toggleables = require("client.playerUI")


components.project("clickToOpenUI", "clickable")

local function toggle(ent)
    if ui.isOpen(ent) then
        ui.close(ent)
    else
        toggleables.openAllControlled()
        ui.open(ent)
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

