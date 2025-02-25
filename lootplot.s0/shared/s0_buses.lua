

local CURSE_RARITIES = {
    [lp.rarities.CURSE_1] = true;
    [lp.rarities.CURSE_2] = true;
    [lp.rarities.CURSE_3] = true
}


umg.answer("lootplot:canRemoveItem", function(itemEnt, ppos)
    if itemEnt.rarity and CURSE_RARITIES[itemEnt.rarity] then
        return false
    end
    return true
end)

