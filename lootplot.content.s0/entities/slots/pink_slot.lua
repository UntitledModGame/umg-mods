local loc = localization.newLocalizer()

return lp.defineSlot("lootplot.content.s0:pink_slot", {
    image = "pink_slot",
    name = loc("Pink Slot"),
    description = loc("Gives an extra life to item.\n(Doesn't work on {lootplot:DOOMED_COLOR}{wavy}DOOMED{/wavy}{/lootplot:DOOMED_COLOR} items.)"),

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt and (not itemEnt.doomCount) then
            itemEnt.lives = (itemEnt.lives or 0) + 1
        end
    end
})

