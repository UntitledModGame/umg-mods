
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


local loc = localization.localize

local PROP_DISPLAY_NAMES = {
    pointsGenerated = loc("Points-Generated"),
    moneyGenerated = loc("Money-Earned"),
    price = loc("Price"),
    maxActivations = loc("Max-Activations"),
}

local PROP_UPGRADE_DESC = localization.newInterpolator("Increases %{prop} by %{val}")


local propertyUpgradeTc = typecheck.assert("string", "number", "number?")
---@param prop string
---@param startValue number
---@param growthRate? number
---@return table
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

    local tierUpgrade = {
        upgrade = function(ent, _srcEnt, oldTier, newTier)
            local exponent = newTier - 1
            local newVal = startValue * (growthRate ^ exponent)
            newVal = math.floor(newVal + 0.5)
            ent[baseProp] = newVal
            -- we dont need to sync `baseProp`; coz the property 
            --  is computed serverside only, and sent over to client anyway.
        end,
        description = function(ent)
            return PROP_UPGRADE_DESC({
                prop = PROP_DISPLAY_NAMES[prop],
                val = (ent[baseProp] * (growthRate-1))
            })
        end
    }
    return tierUpgrade
end



local POINT_MULT_UPGR_DESC = localization.newInterpolator("Gives a %{mult} multiplier to Points-Generated")

---@param mult number
---@return table
function helper.pointsMultUpgrade(mult)
    assert(mult,"?")
    local tierUpgrade = {
        upgrade = function(ent, _srcEnt, oldTier, newTier)
        end,
        description = POINT_MULT_UPGR_DESC({
            mult = mult
        })
    }
    return tierUpgrade
end



return helper
