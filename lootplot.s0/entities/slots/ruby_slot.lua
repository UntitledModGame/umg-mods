
local loc = localization.localize


local function pulseItem(slotEnt)
    local ppos = lp.getPos(slotEnt)
    local item = lp.slotToItem(slotEnt)
    if ppos and item and lp.canActivateEntity(item) and lp.hasTrigger(item, "PULSE") then
        lp.queueWithEntity(slotEnt, pulseItem)
        lp.tryTriggerEntity("PULSE", item)
        lp.wait(ppos, 0.25)
    end
end


return lp.defineSlot("lootplot.s0:ruby_slot", {
    image = "ruby_slot",
    name = loc("Ruby slot"),
    baseMaxActivations = 100,
    triggers = {"PULSE"},
    activateDescription = loc("Causes item to {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} up to 100 times!\n(Uses all activations)"),

    rarity = lp.rarities.RARE,

    onActivate = function(slotEnt)
        local ppos = lp.getPos(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not (ppos and itemEnt) then return end

        lp.queueWithEntity(slotEnt, pulseItem)
    end
})

