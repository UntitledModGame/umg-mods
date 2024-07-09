

local function initPlayer(ent, clientId)
    assert(clientId,"?")
    ent.controller = clientId
end

return umg.defineEntityType("lootplot:player", {
    speed = 600,
    cameraFollow = true;

    image = "player",

    init = initPlayer,
})

