


local PSYS = love.graphics.newParticleSystem(client.atlas:getTexture(), 30)
PSYS:setQuads(
    assert(client.assets.images.spark_1),
    assert(client.assets.images.spark_2),
    assert(client.assets.images.spark_3)
)

umg.on("rendering:drawEntity", function(ent)
    if lp.isItemEntity(ent) then
        
    end
end)