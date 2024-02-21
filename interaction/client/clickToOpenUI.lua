

local getAuthorizedControlEntity = require("client.getAuthControlEnt")




umg.on("clickables:entityClickedClient", function(ent, button, worldX, worldY)
    if ent.clickToOpenUI then
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            ui.open(ent)
        end
    end
end)

