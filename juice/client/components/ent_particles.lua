
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





local function updateParticleTable(ent, ptable, dt)
    if not ptable.particleSystem then
        ptable.particleSystem = getPsys(ptable)
    end

    if ent:isRegular("particles") and ent.shouldEmitParticles then
        local emitting = ent:shouldEmitParticles()
        local psys = ptable.particleSystem
        if emitting and psys:isStopped() then
            psys:start()
        elseif (not emitting) and (not psys:isStopped()) then
            psys:stop()
        end
    end

    if (ptable.last_update or 0) < frameCount then
        -- this ensures that particle systems aren't updated twice if they are
        -- shared between entities.
        ptable.particleSystem:update(dt)
        ptable.last_update = frameCount
    end
end


umg.on("state:gameUpdate", function(dt)
    for _, ent in ipairs(particleEntities)do
        ent.particles:setPosition(ent.x, ent.y)
        ent.particles:update(dt)
    end
end)



local function drawParticleTable(ent, ptable)
    local isShared = ent:isShared("particles")
    if ptable.particleSystem then
        local ox, oy = 0,0
        if ptable.offset then
            ox = ptable.offset.x or ox
            oy = ptable.offset.y or oy
        end

        if isShared then
            if ent.shouldEmitParticles and (not ent:shouldEmitParticles()) then
                return
            end
            love.graphics.draw(ptable.particleSystem, ent.x + ox, ent.y + oy)
        else
            ptable.particleSystem:setPosition(ent.x, ent.y)
            love.graphics.draw(ptable.particleSystem, ox, oy)
        end
    end
end


umg.on("rendering:drawEntity", function(ent)
    if ent.particles then
        local ox,oy = getParticleOffset(ent)
        love.graphics.draw(ent.particles, ox,oy)
    end
end)


