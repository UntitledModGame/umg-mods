
local COMBO_CAP = 20 -- maxes out at after combo count is X

local MAX_SPEED = 5 -- max speed is X times faster


local function getSpeed(cmbo)
    local spd = math.clamp((cmbo-1) / COMBO_CAP, 0, 1)
    local mult = 1+(spd * MAX_SPEED)
    return mult
end

umg.answer("lootplot:getPipelineDelayMultiplier", function(plot)
    local e = plot:getOwnerEntity()
    local combo = lp.getCombo(e)
    if combo then
        return 1/getSpeed(combo)
    end
    return 1
end)
