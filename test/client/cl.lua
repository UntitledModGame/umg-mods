

base.client.groundTexture.setDefaultGround({
    images = {"ground_texture_final4"},
    color = {0.3,0.9,0.55}
})



umg.on("@load", function()
    vignette.setStrength(0.65)
end)


umg.on("@createWorld", function()
    base.client.groundTexture.setGround("overworld", {
        images = {"ground_texture_final4"},
        color = {0.7,0.7,0.7}
    })
end)





love.graphics.clear()


local psys = juice.particles.newParticleSystem({
    "circ4", "circ3", "circ2", "circ1"
})


juice.particles.define("smoke", psys)





local listener = input.Listener({priority = 2})


local function getPlayerWithXY()
    --[[
        this sucks!
        PLS dont use this code in real world.
        It doesn't work for multiplayer.
        entities will only chase the host.
    ]]
    local clientId = client.getUsername()
    local ents = control.getControlledEntities(clientId)
    for _, e in ipairs(ents) do
        if e.x and e.y then
            return e
        end
    end
end



umg.group():onAdded(function(ent)
    assert(ent.id,"spawned ent doesnt have id?")
    print(ent)
end)


local drawGroup = umg.group("drawable", "x", "y")


function listener:keypressed(key, scancode, isrepeat)
    if scancode == "q" then
        error("stop")
    end
    if scancode == "e" then
        print("size drawGroup: ", #drawGroup)
    end
    if scancode == "space" then
        local e = getPlayerWithXY()
        if base.gravity.isOnGround(e) then
            e.vz = 400
        end
    end
end


umg.on("@draw", function()
    local p = getPlayerWithXY()
    if p then
        love.graphics.setColor(0,0,0)
        love.graphics.print(dimensions.getDimension(p))
    end
end)



