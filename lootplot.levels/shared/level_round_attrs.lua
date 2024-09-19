

lp.defineAttribute("LEVEL")

lp.defineAttribute("ROUND")

--[[
QUESTION:

What is the difference between a "level" and "round"??
A: well, they are both number-properties, so they can be interpreted 
however you want, lol.

But, "LEVEL" is *supposed* to be used as a general difficulty indicator.
higher level = higher difficulty

"ROUND" is supposed to be used as general indicator that is reset sporadically.
For example, there could be multiple rounds per level.

----

TODO:
in future, maybe we should make LEVEL and ROUND be in seperate mods??
eh, who cares for now, i got no bloody time

]]


assert(not lp.levels, "?")
lp.levels = {}


---Availability: **Server**
---@param ent Entity
---@param x number
function lp.levels.setLevel(ent, x)
    return lp.setAttribute("LEVEL", ent, x)
end

---Availability: Client and Server
---@param ent Entity
function lp.levels.getLevel(ent)
    return lp.getAttribute("LEVEL", ent)
end


---Availability: **Server**
---@param ent Entity
---@param x? number
function lp.levels.setRound(ent, x)
    return lp.setAttribute("ROUND", ent, x)
end

---Availability: Client and Server
---@param ent Entity
function lp.levels.getRound(ent)
    return lp.getAttribute("ROUND", ent)
end

