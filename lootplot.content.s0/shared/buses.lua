umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt, itemEnt)
    if lp.hasTrait(itemEnt, "lootplot.content.s0:PLANT_TRAIT") then
        return lp.hasTrait(slotEnt, "lootplot.content.s0:PLANT_TRAIT")
    end

    return false
end)
