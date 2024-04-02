

local function initPlayer(ent, clientId)
    assert(clientId,"?")
    ent.controller = clientId
end

return umg.defineEntityType("lootplot:player", {
    topdownControl = {};

    initXY = true,
    init = initPlayer,
})

