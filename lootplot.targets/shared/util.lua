local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end

return util
