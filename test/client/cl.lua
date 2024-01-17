

base.client.groundTexture.setDefaultGround({
    images = {"ground_texture_final4"},
    color = {0.3,0.9,0.55}
})




umg.on("@load", function()
    vignette.setStrength(0.65)

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






function listener:keypressed(key, scancode, isrepeat)
    if scancode == "q" then
        local e = getPlayerWithXY()
        local x, y = rendering.getWorldMousePosition()
        juice.particles.emit("smoke", e, 10, {0.2,0.8,0.9})
        e.x = x
        e.y = y
        juice.particles.emit("smoke", e, 10)
    end
    if scancode == "e" then
        local e = getPlayerWithXY()
        juice.shockwave({
            x = e.x, y = e.y,
            dimension = e.dimension,
            type = "fill",
            color = {0.1,0.3,0.9},
            endColor = {0.5,0.6,1,1},
            duration = 0.25
        })
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



