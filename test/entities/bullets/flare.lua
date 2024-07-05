

local SHAPE = love.physics.newCircleShape(1)



local flareParticles
if client then
    --[[
    TODO do particles
    ]]
end


return umg.defineEntityType("flare", {
    rotateOnMovement = true,
    drawable = true,

    image = "shotgunshell",

    physics = {
        shape = SHAPE,
        --type = "kinematic"
    },

    light = {
        size = 500,
        color = {1,0.95,0.95}
    }
})

