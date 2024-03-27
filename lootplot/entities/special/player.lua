
local Plot = require("shared.Plot")



local function initPlayer(ent, clientId)
    assert(clientId,"?")

    local w,h = constants.PLAYER_INVENTORY_WIDTH, constants.PLAYER_INVENTORY_HEIGHT
    ent.plot = Plot(ent, w,h)
    ent.inventory = items.Inventory({entity=ent, size=w*h})

    ent.plot:foreach(function(ppos)
        setSlot(ppos, server.entities.slot())
    end)

    ent.controller = clientId
end

local function initUI(ent)
    local PlotInventoryElement = require("client.PlotInventoryElement")
    local element = PlotInventoryElement({
        entity = ent
    })
end


return umg.defineEntityType("lootplot:player", {
    toggleableUI = true,
    uiSize = {width = 0.4, height = 0.2},
    clampedUI = true,

    topdownControl = {};

    initXY = true,
    init = initPlayer,
    initUI = initUI
})

