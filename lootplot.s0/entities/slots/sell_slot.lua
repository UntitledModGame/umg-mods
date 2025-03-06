local loc = localization.localize

lp.defineSlot("lootplot.s0:sell_slot", {
    image = "sell_slot",
    name = loc("Sell slot"),
    activateDescription = loc("Reduce item price by half, and earn {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} equal to the price.\nThen, destroy item."),

    triggers = {"PULSE"},

    baseCanSlotPropagate = false,
    isItemListenBlocked = true,

    baseMaxActivations = 500,

    rarity = lp.rarities.UNCOMMON,

    canActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not itemEnt then
            return false -- no item!
        end
    end,

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not itemEnt then
            return
        end

        local price = (itemEnt.price or 0)
        lp.modifierBuff(itemEnt, "price", -price/2, slotEnt)
        lp.addMoney(itemEnt, itemEnt.price or 0)
        lp.destroy(itemEnt)
    end
})
