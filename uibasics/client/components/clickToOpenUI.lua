

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local toggleables = require("client.toggleables")


components.project("clickToOpenUI", "clickable")

local function toggle(ent)
    if uiBasics.isOpen(ent) then
        uiBasics.close(ent)
    else
        -- when opening a chest; we ALSO want to open the player inventory(s)
        toggleables.openAllControlled()
        uiBasics.open(ent)
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

