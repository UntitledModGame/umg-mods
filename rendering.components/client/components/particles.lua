
--[[

particle emitters for entities.

If an entity has a `particles` component,
it will emit particles as it moves.

]]


local particleEntities = umg.group("particles")

components.project("particles", "drawable")




particleEntities:onAdded(function(ent)
    if ent.particles then
        assert(ent.particles:typeOf("ParticleSystem"))
    end
end)



local function hasPosition(ent)
    return ent.x and ent.y
end

umg.on("@update", function(dt)
    for _, ent in ipairs(particleEntities)do
        ent.particles:update(dt)
        if hasPosition(ent) then
            -- if ent has a position, then the emitter should follow the ent!
            -- (This makes it so particles look nice when the entity moves)
            ent.particles:setPosition(ent.x, ent.y)
        else
            -- Else, if ent DOESN'T have a position, then, the emitter
            -- should be set to 0.
            ent.particles:setPosition(0, 0)
        end
    end
end)




local lg=love.graphics

umg.on("rendering:drawEntity", function(ent, x,y, rot,sx,sy)
    if ent.particles then
        lg.push()
        if hasPosition(ent) then
            -- particle emitter position is already baked in;
            -- (See update func above.)
            x, y = 0, 0
        end
        lg.scale(sx,sy)

        -- TODO: Maybe we provide a way to offset particles here.
        -- Perhaps an entirely new component: ent.particleOptions..?
        local ox, oy = 0, 0
        lg.draw(ent.particles, x+ox, y+oy)
        lg.pop()
    end
end)


