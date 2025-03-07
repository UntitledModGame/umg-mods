

local entityProperties = {}

local umg_ask = umg.ask


---@param ent Entity
---@return number
function entityProperties.getRotation(ent)
    return (ent.rot or 0) + umg_ask("rendering:getRotation", ent)
end


---@param ent Entity
---@return number
function entityProperties.getScale(ent)
    return (ent.scale or 1) * umg_ask("rendering:getScale", ent)
end


---@param ent Entity
---@return number,number
function entityProperties.getScaleXY(ent)
    local sx, sy = umg_ask("rendering:getScaleXY", ent)
    return (ent.scaleX or 1) * sx, (ent.scaleY or 1) * sy
end

---@param ent Entity
---@return number,number
function entityProperties.getOffsetXY(ent)
    local ox, oy = umg_ask("rendering:getOffsetXY", ent)
    return (ent.ox or 0) + ox, (ent.oy or 0) + oy
end

---@param ent Entity
---@return number,number
function entityProperties.getShearXY(ent)
    local kx, ky = umg_ask("rendering:getShearXY", ent)
    return (ent.shearX or 0) + kx, (ent.shearY or 0) + ky
end


---@param ent Entity
---@return number
function entityProperties.getOpacity(ent)
    local a = 1
    if ent.color and ent.color[4] then
        a = ent.color[4]
    end
    return a * (ent.opacity or 1) * umg_ask("rendering:getOpacity", ent)
end



---@param ent Entity
---@return number,number,number
function entityProperties.getColor(ent)
    local r,g,b = umg_ask("rendering:getColor", ent)

    local color = ent.color
    if color then
        return r*color[1], g*color[2], b*color[3]
    end
    return r,g,b
end


---@param ent Entity
---@return string?
function entityProperties.getImage(ent)
    return umg_ask("rendering:getImage", ent) or ent.image
end


---@param ent Entity
---@return boolean
function entityProperties.isHidden(ent)
    return (not not ent.hidden) or (not not umg_ask("rendering:isHidden", ent))
end


return entityProperties
