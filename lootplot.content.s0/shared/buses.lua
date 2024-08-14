umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt, itemEnt)
    if lp.hasTrait(itemEnt, "lootplot.content.s0:BOTANIC") then
        return lp.hasTrait(slotEnt, "lootplot.content.s0:BOTANIC")
    end

    return false
end)
