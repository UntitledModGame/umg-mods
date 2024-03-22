
local PlotInventory = require("shared.PlotInventory")
local Plot = require("shared.Plot")



local function initPlayer(ent, clientId)
    assert(clientId,"?")

    local w,h = constants.PLAYER_INVENTORY_WIDTH, constants.PLAYER_INVENTORY_HEIGHT
    ent.plot = Plot(ent, w,h)
    ent.inventory = PlotInventory({
        entity = ent
    })

    ent.controller = clientId
end

local function initUI(ent)
    local PlotInventoryElement = require("client.PlotInventoryElement")
    ent.uiElement = PlotInventoryElement({
        plot = ent.plot
    })
end


return umg.defineEntityType("lootplot:player", {
    toggleableUI = true,
    draggableUI = true,
    uiSize = {width = 0.7, height = 0.25},

    topdownControl = {};

    initXY = true,
    init = initPlayer,
    initUI = initUI
})

