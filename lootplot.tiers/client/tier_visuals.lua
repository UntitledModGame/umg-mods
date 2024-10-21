

local TIER_IMAGES = {--[[
    [tier-number] -> image-name
]]}


for tier=2, 4 do
    local img = "tier_"..tostring(tier)
    TIER_IMAGES[tier] = img
end

local AFTER=10
umg.on("rendering:drawEntity", AFTER, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) and ent.tier then
        local img = TIER_IMAGES[ent.tier]
        if img then
            local ox, oy = -5, -4
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        end
    end
end)


