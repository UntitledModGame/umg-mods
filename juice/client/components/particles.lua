
--[[

particle emitters for entities.

If an entity has a `particles` component,
it will emit particles as it moves.

]]


local particleEntities = umg.group("particles", "x", "y")

components.project("particles", "drawable")




particleEntities:onAdded(function(ent)
    if ent.particles then
        assert(ent.particles:typeOf("ParticleSystem"))
    end
end)




umg.on("state:gameUpdate", function(dt)
    for _, ent in ipairs(particleEntities)do
        ent.particles:setPosition(ent.x, ent.y)
        ent.particles:update(dt)
    end
end)





umg.on("rendering:drawEntity", function(ent)
    if ent.particles then
        --[[
            TODO:
            Maybe we provide a way to offset particles here.
            Perhaps an entirely new component:
            ent.particleOptions = {
                shouldEmit = func,
                ox = 0,
                oy = 10
            }
        ]]
        local ox, oy = 0, 0
        love.graphics.draw(ent.particles, ox,oy)
    end
end)


