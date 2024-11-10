

local function getSpeed(level)
    local speedMult = math.max(1, (level ^ 1.4) / 4)
    return speedMult
end



umg.answer("lootplot:getPipelineDelayMultiplier", function(plot)
    local e = plot:getOwnerEntity()
    local level = lp.getLevel(e)
    if level then
        return 1/getSpeed(level)
    end
    return 1
end)


