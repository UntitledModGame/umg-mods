
local loc = localization.localize


local ROTATE_BUTTON_COST = 2

return lp.defineSlot("lootplot.s0.content:rotate_slot", {
    image = "rotate_slot",
    name = loc("Rotate Slot"),

    baseCanSlotPropagate = false,

    triggers = {"PULSE"},

    activateDescription = loc("Rotates item\n(Without activating it!)"),

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            lp.rotateItem(itemEnt, 1)
        end
    end,

    actionButtons = {
        {
        text = loc("Rotate ($2)"),
        action = function(selfEnt)
            if server then
                if lp.canActivateEntity(selfEnt) and (lp.getMoney(selfEnt) or 0) >= ROTATE_BUTTON_COST then
                    lp.addMoney(selfEnt, -ROTATE_BUTTON_COST)
                    lp.tryActivateEntity(selfEnt)
                end
            end
        end,
        color = lp.targets.TARGET_COLOR
        }
    }
})

