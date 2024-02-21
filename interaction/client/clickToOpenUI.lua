

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local playerUI = require("client.playerUI")


components.project("clickToOpenUI", "clickable")


umg.on("clickables:entityClickedClient", function(ent, button, worldX, worldY)
    if ent.clickToOpenUI then
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            ui.open(ent)
            playerUI.open()
        end
    end
end)

