


umg.answer("lootplot:canRemoveItem", function(itemEnt, ppos)
    --[[
    TODO: should this be somewhere else...? 
    Idk
    ]]
    if lp.curses.isCurse(itemEnt) then
        return false
    end
    return true
end)

