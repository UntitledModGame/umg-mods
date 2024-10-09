
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


return helper

