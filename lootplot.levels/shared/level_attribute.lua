

lp.defineAttribute("LEVEL")

--[[

"LEVEL" is *supposed* to be used as a general difficulty indicator.
higher level = higher difficulty.

Also, more "advanced" stuff should be available at higher levels.
(For example; RARE items could only generate after level 4, for example)

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

