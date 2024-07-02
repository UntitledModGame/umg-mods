

local function initPlayer(ent, clientId)
    assert(clientId,"?")
    ent.controller = clientId
    ent.money = 0
end

return umg.defineEntityType("lootplot:player", {
    speed = 600,
    topdownControl = {};
    initVxVy = true,
    cameraFollow = true;

    image = "player",

    init = initPlayer,
})

