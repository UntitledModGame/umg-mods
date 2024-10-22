
local helper = {}




local function hasRerollTrigger(ent)
    for _,t in ipairs(ent.triggers)do
        if t == "REROLL" then
            return true
        end
    end
    return false
end


local function shouldReroll(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and hasRerollTrigger(slot) then
        return true
    end
    local item = lp.posToItem(ppos)
    if item and hasRerollTrigger(item) then
        return true
    end
end


function helper.rerollPlot(plot)
    lp.Bufferer()
        :all(plot)
        :filter(shouldReroll)
        :to("SLOT")
        :execute(function(ppos, ent)
            lp.resetCombo(ent)
            lp.tryTriggerEntity("REROLL", ent)
        end)
end


local propertyUpgradeTc = typecheck.assert("string", "number", "number?")
function helper.propertyUpgrade(prop, startValue, growthRate)
    --[[
    propertyUpgrade("pointsGenerated", 2, 5)
    tier-1: 2x(5^0) = 2
    tier-2: 2x(5^1) = 10
    tier-3: 2x(5^2) = 50
    tier-4: 2x(5^3) = 250
    ]]
    propertyUpgradeTc(prop, startValue, growthRate)
    growthRate = growthRate or 3
    local baseProp = assert(properties.getBase(prop))

    return function(ent, _srcEnt, oldTier, newTier)
        local exponent = newTier - 1
        local newVal = startValue * (growthRate ^ exponent)
        ent[baseProp] = newVal
        -- we dont need to sync `baseProp`; coz the property 
        --  is computed serverside only, and sent over to client anyway.
    end
end



local tierLocTc = typecheck.assert("table")
function helper.tierLocalize(tierStrings)
    tierLocTc(tierStrings)
    local tierToString = {}
    for i,v in ipairs(tierStrings) do
        tierToString[i] = localization.localize(v)
    end
    assert(tierToString[1], "Must have at least 1 string")
    return function(ent)
        local tier = lp.tiers.getTier(ent)
        if tierToString[tier] then
            return tierToString[tier]
        end
        return tierToString[1]
    end
end




return helper

