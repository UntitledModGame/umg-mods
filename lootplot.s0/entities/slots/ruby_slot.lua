
local loc = localization.localize


local PULSE_COUNT = 4


local function doPulse(itemEnt)
    lp.tryTriggerEntity("PULSE", itemEnt)
end


return lp.defineSlot("lootplot.s0:ruby_slot", {
    image = "ruby_slot",
    name = loc("Ruby slot"),
    baseMaxActivations = 100,
    triggers = {"PULSE"},
    activateDescription = loc("Causes item to {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} %{count} times!", {
        count = PULSE_COUNT
    }),

    rarity = lp.rarities.RARE,

    onActivate = function(slotEnt)
        local ppos = lp.getPos(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not (ppos and itemEnt) then return end

        if ppos and itemEnt and lp.canActivateEntity(itemEnt) and lp.hasTrigger(itemEnt, "PULSE") then
            for _=1, PULSE_COUNT do
                lp.wait(ppos, 0.15)
                lp.queueWithEntity(itemEnt, doPulse)
                lp.wait(ppos, 0.15)
            end
        end
    end
})

