

local function shouldApplyEffect(effectEnt, ownerEnt)
    local blocked = umg.ask("effects:isEffectBlocked", effectEnt, ownerEnt)
    return not blocked
end


return shouldApplyEffect
