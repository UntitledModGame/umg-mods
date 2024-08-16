local function makeSparkPS(count)
    local spark = love.graphics.newParticleSystem(client.atlas:getTexture(), count)
    spark:setQuads(
        assert(client.assets.images.spark_1),
        assert(client.assets.images.spark_2),
        assert(client.assets.images.spark_3)
    )
    spark:setParticleLifetime(0.1, 0.5)
    spark:setEmissionArea("ellipse", 10, 10, 0, true)
    spark:setRotation(0, math.pi * 2)
    spark:setLinearDamping(5, 10)
    spark:setSpeed(-55, 55)
    spark:setColors(objects.Color.YELLOW)
    return spark
end

local function makeSpark(ent, count)
    local newEnt = client.entities.empty()
    newEnt.x, newEnt.y = ent.x, ent.y
    newEnt.dimension = ent.dimension
    newEnt.lifetime = 1
    -- ^^^ delete self after X seconds
    local ps = makeSparkPS(count)
    ps:setPosition(ent.x, ent.y)
    ps:emit(count)
    newEnt.particles = ps
    newEnt.drawDepth = 100
end

umg.on("lootplot:comboChanged", function(ent, delta, oldVal, newVal)
    if newVal > 2 then
        local particleCount = math.floor(math.sqrt(newVal) * 1)
        makeSpark(ent, particleCount)
    end
end)
