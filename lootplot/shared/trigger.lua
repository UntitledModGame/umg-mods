local triggerInfo = {}

local trigger = {}

umg.answer("lootplot:canTrigger", function()
    return true -- need this for AND reducer
end)


typecheck.addType("trigger", function(x)
    return type(x) == "string" and triggerInfo[x], "expected trigger"
end)

---@param name string
function trigger.defineTrigger(name)
    assert(not triggerInfo[name], "trigger name already defined")
    triggerInfo[name] = true
end

local triggerTc = typecheck.assert("trigger", "entity")

local EMPTY = {}

---@param name string
---@param ent Entity
function trigger.triggerEntity(name, ent)
    assert(server, "server-side function only")
    triggerTc(name, ent)

    local canTrigger = trigger.canTrigger(name, ent)
    if canTrigger then
        umg.call("lootplot:entityTriggered", name, ent)
        lp.tryActivateEntity(ent)
    end

    -- TODO: should this be inside the `if canTrigger` if block???
    if ent.slot and ent.canSlotPropagate then
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            trigger.triggerEntity(name, itemEnt)
        end
    end
end

---@param name string
---@param ent Entity
---@return boolean
function trigger.canTrigger(name, ent)
    local ok = umg.ask("lootplot:canTrigger", name, ent)
    if not ok then
        return false
    end
    local triggers = ent.triggers or EMPTY
    for _, t in ipairs(triggers) do
        if t == name then
            return true
        end
    end
    return false
end


sync.proxyEventToClient("lootplot:entityTriggered")

trigger.defineTrigger("REROLL")
trigger.defineTrigger("PULSE")
trigger.defineTrigger("RESET")
trigger.defineTrigger("DESTROY")

---@alias lootplot.Trigger "REROLL"|"PULSE"|"RESET"|"DESTROY"

return trigger
