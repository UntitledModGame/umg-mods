

local function initPlayer(ent, clientId)
    assert(clientId,"?")
    ent.controller = clientId
end

return umg.defineEntityType("lootplot:player", {
    speed = 300,
    cameraFollow = true;

    topdownControl = {},

    init = initPlayer,
})

