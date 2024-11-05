local loc = localization.localize

lp.defineSlot("lootplot.s0.content:sell_slot", {
    image = "sell_slot",
    name = loc("Sell slot"),
    activateDescription = loc("Sells (and destroys) items for half the price."),
    triggers = {"PULSE"},
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,

    canActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not itemEnt then
            return false -- no item!
        end
        local money = lp.getMoney(itemEnt)
        local price = (itemEnt.price or 0) / 2
        if (price + money) < 0 then
            return false -- not enough money!
            -- (sell-price is negative)
        end
        return true
    end,

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if not itemEnt then
            return
        end

        local price = (itemEnt.price or 0) / 2
        lp.addMoney(itemEnt, price)
        lp.destroy(itemEnt)
    end
})
