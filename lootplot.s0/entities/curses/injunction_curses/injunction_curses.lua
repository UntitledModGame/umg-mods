
--[[

==============================
INJUNCTION CURSES
==============================

Injunction curses should spawn at the START of a run.
Usually disables a certain playstyle.


- Null-slots get turned to stone
- Glass-slots get turned to stone
- Slots that earn bonus or points get turned to stone
- All slots without DOOMED are given DOOMED-25
- All items with Repeater get transformed into manure
- All items with Grubby get transformed into manure
- All items that earn bonus get transformed into manure
- All items that subtract bonus get transformed into manure
- All items that earn money get transformed into manure
- All items with Destroy trigger get transformed into manure
- All items with Rotate trigger get transformed into manure
- Subtract -1 activations from ALL items (cannot go below 1)
- All items with a modified {col}shape{/col} get transformed into manure
- All items with modified {col}triggers{/col} get transformed into manure


]]

local loc = localization.localize
local interp = localization.newInterpolator




local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end

    lp.defineItem("lootplot.s0:" .. (id), etype)
end


---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getSlots(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    local plot = ppos:getPlot()
    local team = ent.lootplotTeam
    plot:foreachSlot(function(slotEnt, slotPos)
        local filterOk = (not filter) or filter(slotEnt, slotPos)
        local fogRevealed = plot:isFogRevealed(slotPos, team)
        if filterOk and fogRevealed then
            ret:add(slotEnt)
        end
    end)
    return ret
end


---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getSlotsNoButtons(ent, filter)
    return getSlots(ent, function(slotEnt, slotPos)
        if slotEnt.buttonSlot then
            return false
        end
        local filterOk = (not filter) or filter(slotEnt, slotPos)
        return filterOk
    end)
end




---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getItems(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachItem(function(itemEnt, pos)
        local filterOk = ((not filter) or filter(itemEnt, pos))
        local isCurse = lp.curses.isCurse(itemEnt)
        if itemEnt ~= ent and filterOk and (not isCurse) then
            ret:add(itemEnt)
        end
    end)
    return ret
end



defCurse("doomed_injunction", "Doomed Injunction", {

})

