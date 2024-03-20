

local SHAPE = love.physics.newCircleShape(1)



local flareParticles
if client then
    flareParticles = juice.newParticleSystem({
        "circ4", "circ3", "circ2", "circ1"
    })
    flareParticles:setParticleLifetime(0.4,0.9)
    flareParticles:setColors(
        1,1,1,1,
        0.6,0.6,0.6,0.5
    )
    flareParticles:setEmissionRate(100) -- TODO: this doesn't FRICKEN work!!!!
    flareParticles:setEmissionArea("uniform", 1, 1, 0)
end


return umg.defineEntityType("flare", {
    rotateOnMovement = true,
    drawable = true,

    image = "shotgunshell",

    particles = flareParticles,

    physics = {
        shape = SHAPE,
        --type = "kinematic"
    },

    light = {
        size = 500,
        color = {1,0.95,0.95}
    }
})

