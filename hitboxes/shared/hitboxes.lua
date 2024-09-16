---@meta

---Availability: Client and Server
---@class hitboxes.mod
local hitboxes = {}
if false then
    _G.hitboxes = hitboxes
end

components.project("hitboxDistance", "hitboxable")
components.project("hitboxArea", "hitboxable")

---This one handles the AABB hitbox
---@param ent Entity
---@param x number
---@param y number
umg.answer("hitboxes:inRange", function(ent, x, y)
    if ent.hitboxArea then
        local area = ent.hitboxArea
        local ew, eh = area.width, area.height
        local ex = ent.x + (-ew / 2) + (area.ox or 0)
        local ey = ent.y + (-eh / 2) + (area.oy or 0)
        return x >= ex and y >= ey and x < (ex + ew) and y < (ey + eh)
    end

    return false
end)

---This one handles the circle hitbox
---@param ent Entity
---@param x number
---@param y number
umg.answer("hitboxes:inRange", function(ent, x, y)
    if ent.hitboxDistance then
        return math.sqrt((ent.x - x) ^ 2 + (ent.y - y) ^ 2) <= ent.hitboxDistance
    end

    return false
end)

---Check if the specified X-Y point is inside entity hitbox.
---
---Availability: Client and Server
---@param ent Entity
---@param x number
---@param y number
---@return boolean
function hitboxes.isHit(ent, x, y)
    return not not (ent.hitboxable and umg.ask("hitboxes:inRange", ent, x, y))
end

---Check if the specified entity has hitbox.
---
---Entity without hitbox always have `hitboxes.isHit` returning false, but `hitboses.isHit` does not necessarily mean
---the entity does not have hitbox.
---
---Availability: Client and Server
---@param ent Entity
---@return boolean
function hitboxes.hasHitbox(ent)
    return not not ent.hitboxable
end

umg.expose("hitboxes", hitboxes)
return hitboxes
