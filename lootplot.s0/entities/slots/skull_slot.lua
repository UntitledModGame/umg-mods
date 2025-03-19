
local loc = localization.localize


local function tryDestroyItem(slotEnt)
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.destroy(itemEnt)
    end
end

lp.defineSlot("lootplot.s0:skull_slot", {
    image = "skull_slot",
    name = loc("Skull slot"),
    activateDescription = loc("Destroys item 3 times."),
    triggers = {"PULSE"},
    dontPropagateTriggerToItem = true,
    baseMaxActivations = 500,

    isItemListenBlocked = true,

    rarity = lp.rarities.RARE,

    canActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            return true
        end
    end,

    onActivate = function(slotEnt)
        local ppos = lp.getPos(slotEnt)
        if not ppos then return end
        lp.wait(ppos, 0.2)
        lp.queueWithEntity(slotEnt, tryDestroyItem)
        lp.wait(ppos, 0.2)
        lp.queueWithEntity(slotEnt, tryDestroyItem)
        lp.wait(ppos, 0.2)
        lp.queueWithEntity(slotEnt, tryDestroyItem)
    end
})

