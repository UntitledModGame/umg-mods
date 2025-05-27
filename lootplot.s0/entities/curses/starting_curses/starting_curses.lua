
--[[

==============================
STARTING CURSES
==============================

these are curses that should spawn at the START of a run.
They usually augment the game a lot, and are more than "an annoyance."

Generally, these curses will force a certain playstyle.

]]

local loc = localization.localize


local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    etype.canItemFloat = true

    lp.defineItem("lootplot.s0:" .. (id), etype)
end



local function getSlots(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachSlot(function(slotEnt, slotPos)
        if (not filter) or filter(slotEnt, slotPos) then
            ret:add(slotEnt)
        end
    end)
    return ret
end



local function getItems(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachItem(function(itemEnt, pos)
        if (not filter) or filter(itemEnt, pos) then
            ret:add(itemEnt)
        end
    end)
    return ret
end





local function getClosestSlot(ent, filter)
    
end



defCurse("anti_bonus_contract_curse", "Anti Bonus Contract", {
    description = loc("Whilst this curse exists, {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} cannot go higher than -1."),

    onUpdateServer = function(ent)
        if lp.getPointsBonus(ent) > -1 then
            lp.setPointsBonus(ent, -1)
        end
    end
})



defCurse("anti_bonus_contract_curse", "Anti Bonus Contract", {
    description = loc("Whilst this curse exists, {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} cannot go higher than -1."),

    onUpdateServer = function(ent)
        if lp.getPointsBonus(ent) > -1 then
            lp.setPointsBonus(ent, -1)
        end
    end
})

