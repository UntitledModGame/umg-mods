
local util = require("shared.util")


local TIER_TO_PSYS = {--[[
    [tier-number] -> psys
]]}

local TIER_IMAGES = {--[[
    [tier-number] -> image-name
]]}


for tier=2, 4 do
    local img = "tier_"..tostring(tier)
    TIER_IMAGES[tier] = img

    local psys = love.graphics.newParticleSystem(client.atlas:getTexture(), 30)
    psys:setQuads(
        assert(client.assets.images[img])
    )
    psys:setEmissionRate(4)
    psys:setEmissionArea("uniform", 8, 8)
    psys:setSpeed(4,4)
    psys:setDirection(-math.pi/2)
    psys:setParticleLifetime(0.4,0.6)
    psys:setPosition(0,0)
    psys:setColors({1,1,1}, {1,1,1,0})
    TIER_TO_PSYS[tier] = psys
end


umg.on("@update", function(dt)
    for tier, psys in pairs(TIER_TO_PSYS) do
        psys:update(dt)
    end
end)




local function tryDrawParticles(ent, x,y)
    local ppos = lp.getPos(ent)
    if not ppos then return end
    local shouldDraw = false
    util.forNeighborItems(ppos, function(targEnt)
        if util.canCombine(ent, targEnt) then
            shouldDraw = true
        end
    end)

    if shouldDraw then
        local tier = ent.tier + 1
        local psys = TIER_TO_PSYS[tier]
        if psys then
            love.graphics.draw(psys,x,y)
        end
    end
end


local AFTER=10
umg.on("rendering:drawEntity", AFTER, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) and lp.tiers.canBeUpgraded(ent) then
        tryDrawParticles(ent, x, y)

        local img = TIER_IMAGES[ent.tier]
        if img then
            local ox, oy = -5, -4
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        end
    end
end)

