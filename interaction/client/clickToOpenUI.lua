

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local ownedUI = require("client.ownedUI")



umg.on("clickables:entityClickedClient", function(ent, button, worldX, worldY)
    if ent.clickToOpenUI then
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            ui.open(ent)
            ownedUI.openAllUI()
        end
    end
end)

