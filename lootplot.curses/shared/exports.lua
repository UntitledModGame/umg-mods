


-- boolean comp, determines whether or not something is a curse.
components.defineComponent("isCurse")
-- NOTE: Items AND SLOTS can be curses!


components.defineComponent("curseCount")
-- curseCount defaults to 1 for curses.
-- If curseCount = 2, the item counts as 2 curses.
-- If curseCount = 0, the item isn't included in the count.
-- If curseCount is negative, then it decreases the curse-count!!




assert(not lp.curses, "you lil SHIT! dont overwrite my namespace")
---@class lootplot.curses
local lp_curses = {}



lp_curses.COLOR = {128/255, 17/255, 22/255}




local entityTc = typecheck.assert("entity")

--- Checks if an entity is a curse
---@param ent Entity
---@return boolean
function lp_curses.isCurse(ent)
    entityTc(ent)
    return ent.isCurse
end



local function teamOK(ent, team)
    return (not team) or ent.lootplotTeam == team
end

---@param plot lootplot.Plot
---@param team? string The team to check for (useful for multiplayer)
---@return number count the number of curse-items and curse-slots
function lp_curses.getCurseCount(plot, team)
    local count = 0

    plot:foreachItem(function(ent)
        if lp_curses.isCurse(ent) and teamOK(ent, team) then
            count = count + (ent.curseCount or 1)
        end
    end)
    plot:foreachSlot(function(ent)
        if lp_curses.isCurse(ent) and teamOK(ent, team) then
            count = count + (ent.curseCount or 1)
        end
    end)

    return count
end




---Availability: Client and Server
lp.curses = lp_curses

