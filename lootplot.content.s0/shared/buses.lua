umg.answer("lootplot:canAddItemToSlot", function(slotEnt, itemEnt)
    if lp.hasTrait(itemEnt, "lootplot.content.s0:BOTANIC") then
        return not lp.hasTrait(slotEnt, "lootplot.content.s0:BOTANIC")
    end

    return true
end)
