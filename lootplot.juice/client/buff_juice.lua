local function makeSparkPS(count)
    local spark = love.graphics.newParticleSystem(client.atlas:getTexture(), count)
    spark:setQuads(
        assert(client.assets.images.buff_star_1),
        assert(client.assets.images.buff_star_2),
        assert(client.assets.images.buff_star_3),
        assert(client.assets.images.buff_star_4)
    )
    spark:setParticleLifetime(0.1, 0.7)
    spark:setEmissionArea("ellipse", 13, 13, 0, true)
    return spark
end

local function makeSparkParticles(ent, count)
    if not ent.x or ent.y then return end

    local newEnt = client.entities.empty()
    newEnt.x, newEnt.y = ent.x, ent.y
    newEnt.dimension = ent.dimension
    newEnt.lifetime = 0.7
    -- ^^^ delete self after X seconds
    local ps = makeSparkPS(count)
    ps:setPosition(ent.x, ent.y)
    ps:emit(count)
    newEnt.particles = ps
    newEnt.drawDepth = 100
end

umg.on("lootplot:entityBuffed", function(ent)
    return makeSparkParticles(ent, 12)
end)
