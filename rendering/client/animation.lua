
--[[

Handles animations of entities.

TODO:
Currently, all animation entities have the exact same cycle.
Change this by either (A) adding a manual frame offset, or
(B) offset via entity id.

]]


local animationGroup = umg.group("animation")



local tick = 0

local DEFAULT_ANIM_SPEED = 2 -- seconds to complete animation loop

local EPSILON = 0.00001

local function updateEnt(ent)
    local anim = ent.animation
    local spd = anim.speed or DEFAULT_ANIM_SPEED
    local len = #anim.frames
    local t = tick
    if anim.tick and ent[anim.tick] then
        t = ent[anim.tick]
    end

    -- minus epsilon to ensure that we don't hit the top len value,
    -- plus 1 because of lua's 1-based indexing.
    local frame_i = math.floor(((t % spd) / spd) * len - EPSILON) + 1
    local frame = anim.frames[frame_i]
    ent.image = frame
end


umg.on("@update", function(dt)
    tick = tick + dt
    for i=1, #animationGroup do
        local ent = animationGroup[i]
        updateEnt(ent)
    end
end)




