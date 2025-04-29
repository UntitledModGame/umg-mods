

local loc = localization.localize



lp.defineItem("lootplot.unlocks:key", {
    image = "key",
    name = loc("Key"),

    activateDescription = loc("When placed, triggers {lootplot:TRIGGER_COLOR}Unlock{/lootplot:TRIGGER_COLOR} for slots/items."),

    onUpdateServer = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and (not lp.canSlotPropagateTriggerToItem(slotEnt)) then
            -- dont activate when in null-slots 
            return
        end
        if lp.canActivateEntity(ent) then
            lp.tryActivateEntity(ent)
        end
    end,

    init = function(ent)
        local rot = lp.SEED:randomMisc(0,3)
        if rot ~= 0 then
            lp.rotateItem(ent, rot)
        end
    end,

    doomCount = 1,

    canActivate = function(ent)
        --[[
        Keys will only activate is there is actually an entity TO activate.
        (Or else its a silly waste!)
        ]]
        local targs = lp.targets.getTargets(ent)
        if not targs then return false end
        for _,ppos in ipairs(targs) do
            local item = lp.posToItem(ppos)
            local slot = lp.posToSlot(ppos)
            if item and lp.hasTrigger(item, "UNLOCK") then
                return true
            end
            if slot and lp.hasTrigger(slot, "UNLOCK") then
                return true
            end
        end
        return false
    end,

    shape = lp.targets.HorizontalShape(1),
    target = {
        type = lp.CONVERSIONS.ITEM_OR_SLOT,
        filter = function(_, ppos, targetEnt)
            local item = lp.posToItem(ppos)
            local slot = lp.posToSlot(ppos)
            if item and lp.hasTrigger(item, "UNLOCK") then
                return true
            end
            if slot and lp.hasTrigger(slot, "UNLOCK") then
                return true
            end
            return false
        end,
        activate = function(_, ppos)
            local item = lp.posToItem(ppos)
            local slot = lp.posToSlot(ppos)
            if item then
                lp.tryTriggerEntity("UNLOCK", item)
            end
            if slot then
                lp.tryTriggerEntity("UNLOCK", slot)
            end
        end,
    },
})

