

local getAuthorizedControlEntity = require("client.getAuthControlEnt")
local openAllPlayerUI = require("client.openPlayerUI")



umg.on("clickables:entityClickedClient", function(ent, button, worldX, worldY)
    print("CL CLKT..")
    if ent.clickToOpenUI then
        print("OK HERE.")
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            ui.open(ent)
            openAllPlayerUI()
        end
    end
end)

