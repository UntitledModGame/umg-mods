
local COMBO_CAP = 20 -- maxes out at after combo count is X

local MAX_SPEED = 3 -- max speed is X times faster

local MAX_SEMITONE_OFFSET = 5

local function comboPercentage(cmbo)
    return math.clamp((cmbo-1) / COMBO_CAP, 0, 1)
end

local function getSpeed(cmbo)
    local mult = 1+(comboPercentage(cmbo) * MAX_SPEED)
    return mult
end


if server then

umg.answer("lootplot:getPipelineDelayMultiplier", function(plot)
    local e = plot:getOwnerEntity()
    local combo = lp.getCombo(e)
    if combo then
        return 1/getSpeed(combo)
    end
    return 1
end)

elseif client then
    
umg.answer("audio:getSemitoneOffset", function(name, source, ent)
    if umg.exists(ent) then
        local cmbo = lp.getCombo(ent)
        if cmbo then
            local perc = comboPercentage(cmbo)
            return perc * MAX_SEMITONE_OFFSET
        end
    end
    return 0
end)


end
