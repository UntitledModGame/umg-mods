local triggerInfo = {}

local trigger = {}

umg.answer("lootplot:canTrigger", function()
    return true -- need this for AND reducer
end)


typecheck.addType("trigger", function(x)
    return type(x) == "string" and triggerInfo[x], "expected trigger"
end)

local defineTriggerTc = typecheck.assert("string", "string")

---Availability: Client and Server
---@param id string
---@param displayName string
function trigger.defineTrigger(id, displayName)
    defineTriggerTc(id, displayName)
    assert(not triggerInfo[id], "trigger name already defined")
    triggerInfo[id] = {
        displayName = localization.localize(displayName)
    }
end

local strTc = typecheck.assert("string")

---Availability: Client and Server
---@param id string
---@return string
function trigger.getTriggerDisplayName(id)
    strTc(id)
    assert(trigger.isValidTrigger(id), "Invalid trigger")
    return assert(triggerInfo[id].displayName)
end

---Availability: Client and Server
---@param id string
---@return boolean
function trigger.isValidTrigger(id)
    strTc(id)
    return triggerInfo[id]
end


local triggerTc = typecheck.assert("trigger", "entity")

local EMPTY = {}

---@param name string
---@param ent Entity
function trigger.tryTriggerEntity(name, ent)
    assert(server, "server-side function only")
    triggerTc(name, ent)

    local canTrigger = trigger.canTrigger(name, ent)
    umg.call("lootplot:entityTriggered", name, ent)
    if canTrigger then
        lp.tryActivateEntity(ent)
    else
        umg.call("lootplot:entityTriggerFailed", name, ent)
    end

    -- TODO: should this be inside the `if canTrigger` if block???
    if lp.isSlotEntity(ent) and ent.canSlotPropagate then
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            trigger.tryTriggerEntity(name, itemEnt)
        end
    end
    return canTrigger
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

trigger.defineTrigger("REROLL", "Reroll")
trigger.defineTrigger("PULSE", "Pulse")
trigger.defineTrigger("RESET", "Reset")
trigger.defineTrigger("DESTROY", "Destroyed")
trigger.defineTrigger("BUY", "Buy")
trigger.defineTrigger("ROTATE", "Rotate")

---@alias lootplot.Trigger "REROLL"|"PULSE"|"RESET"|"DESTROY"

return trigger
