local triggerInfo = {}

local trigger = {}

typecheck.addType("trigger", function(x)
    return type(x) == "string" and triggerInfo[x], "expected trigger"
end)

---@param name string
function trigger.defineTrigger(name)
    assert(not triggerInfo[name], "trigger name already defined")
    triggerInfo[name] = true
end

local triggerTc = typecheck.assert("trigger", "entity")

---@param name string
---@param ent Entity
function trigger.triggerEntity(name, ent)
    assert(server, "server-side function only")
    triggerTc(name, ent)
    umg.call("lootplot:entityTriggered", name, ent)

    if ent.triggers then
        for _, t in ipairs(ent.triggers) do
            if t == name then
                -- TODO:::
                -- Should we have implicit buffering here????
                -- ANS: Probably not, no.
                lp.tryActivateEntity(ent)
            end
        end
    end

    if ent.slot and ent.canSlotPropagate then
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            trigger.triggerEntity(name, itemEnt)
        end
    end
end

---@param name string
---@param ent Entity
function trigger.canTrigger(name, ent)
    return not umg.ask("lootplot:isTriggerBlocked", name, ent)
end

sync.proxyEventToClient("lootplot:entityTriggered")

trigger.defineTrigger("REROLL")
trigger.defineTrigger("PULSE")
trigger.defineTrigger("RESET")

---@alias lootplot.Trigger "REROLL"|"PULSE"|"RESET"

return trigger