


umg.answer("lootplot:canRemoveItem", function(itemEnt, ppos)
    if lp.curses.isCurse(itemEnt) then
        return false
    end
    return true
end)

