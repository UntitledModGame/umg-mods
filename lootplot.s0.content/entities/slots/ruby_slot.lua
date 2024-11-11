
local loc = localization.localize


return lp.defineSlot("lootplot.s0.content:ruby_slot", {
    image = "ruby_slot",
    name = loc("Ruby slot"),
    baseMaxActivations = 100,
    canSlotPropagate = false,
    triggers = {"PULSE"},
    activateDescription = loc("Causes item to {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} up to 100 times!\n(Uses all activations)"),

    onActivate = function(slotEnt)
        local ppos = lp.getPos(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not (ppos and itemEnt) then return end

        lp.queueWithEntity(slotEnt, function()
            local item = lp.slotToItem(slotEnt)
            if item and lp.canActivateEntity(item) and lp.hasTrigger(item, "PULSE") then
                lp.tryTriggerEntity("PULSE", item)
                lp.tryActivateEntity(slotEnt)
                lp.wait(ppos, 0.25)
            end
        end)
    end
})

