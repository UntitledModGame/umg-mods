
--[[

Handles moving animation of entities.

TODO:
Currently, all move animation entities have the exact same cycle.
Change this by adding ent's id to the offset.


TODO:
Currently, only 4-directional animations are supported.
Support 2-directional animations please!!!!
(There are a lot of assets with only left-right animations.)



]]



local anim_group = umg.group("moveAnimation", "vx", "vy")



local tick = 0

local DEFAULT_ANIM_SPEED = 2 -- seconds to complete animation loop

local DEFAULT_ANIM_ACTIVATION_SPEED = 5


--[[

TODO: we should change this.
Directions should ideally be a question bus,
rather than being cached here weirdly.

]]
local ent_to_direction = {
    --[[
        [ent] = current_direction_of_this_ent
    ]]
}

--[[
    directions are as follows:
    `up`, `down`, `left`, `right`
]]




anim_group:onAdded(function(ent)
    ent_to_direction[ent] = "down"
end)


anim_group:onRemoved(function(ent)
    ent_to_direction[ent] = nil
end)




local distance = math.distance
local abs = math.abs
local min = math.min
local floor = math.floor


local function getDirFromDirection(dx, dy)
    if abs(dx) > abs(dy) then
        -- Left or Right
        if dx < 0 then
            return "left"
        else
            return "right"
        end
    else
        -- up or down
        if dy < 0 then
            return "up"
        else
            return "down"
        end
    end
end


local function getDirection(ent, speed)
    local dx = ent.vx
    local dy = ent.vy
    if ent.lookX and ent.lookY then
        dx = ent.lookX - ent.x
        dy = ent.lookY - ent.y
    end
    
    if speed > ent.moveAnimation.activation then
        local dir = getDirFromDirection(dx, dy)
        ent_to_direction[ent] = dir
        return dir
    else
        if ent.lookX and ent.lookY then
            return getDirFromDirection(dx,dy)
        else
            return ent_to_direction[ent]
        end
    end
end




local function updateEnt(ent)
    local manim = ent.moveAnimation
    local entspeed = distance(ent.vx, ent.vy)
    
    local dir = getDirection(ent, entspeed) -- should be up, down, left, or right
    local spd = manim.speed or DEFAULT_ANIM_SPEED

    local anim = ent.moveAnimation[dir]
    -- TODO: Chuck an assertion here to ensure that people aren't misusing
    -- the moveAnimation component. (all directions must be defined)
    local len = #anim

    if entspeed > (manim.activation or DEFAULT_ANIM_ACTIVATION_SPEED) then
        local frame_i = min(len, floor(((tick % spd) / spd) * len) + 1)
        local frame = anim[frame_i]
        ent.image = frame
    else
        ent.image = anim[1]
    end
end


umg.on("@update", function(dt)
    tick = tick + dt
    for i=1, #anim_group do
        local ent = anim_group[i]
        updateEnt(ent)
    end
end)

