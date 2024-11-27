local shapeRenamer = {}
local shapes = require("shared.shapes")

local test = {
    shapes.KING_SHAPE,
    shapes.LARGE_KING_SHAPE,

    shapes.RookShape(1),
    shapes.RookShape(2),
    shapes.RookShape(3),
    shapes.RookShape(4),
    shapes.ROOK_SHAPE,

    shapes.BishopShape(1),
    shapes.BishopShape(2),
    shapes.BishopShape(3),
    shapes.BishopShape(4),
    shapes.BISHOP_SHAPE,

    shapes.QueenShape(2),
    shapes.QueenShape(3),
    shapes.QueenShape(4),
    shapes.QUEEN_SHAPE,

    shapes.KNIGHT_SHAPE,
    shapes.ON_SHAPE,
    shapes.ABOVE_SHAPE,
    shapes.BELOW_SHAPE,
    shapes.ABOVE_BELOW_SHAPE,
}

---@type table<lootplot.targets.ShapeData, objects.Set>
local cache = {}

---@param p {[1]:integer,[2]:integer}
local function pos2str(p)
    return p[1].."\0"..p[2]
end

---@param coords {[1]:integer,[2]:integer}[]
function shapeRenamer.get(coords)
    ---@type string[]
    local matches = {}

    for _, t in ipairs(test) do
        if #t.relativeCoords == #coords then
            local set = cache[t]
            if not set then
                -- Build cache
                set = objects.Set()
                for _, pos in ipairs(t.relativeCoords) do
                    set:add(pos2str(pos))
                end

                cache[t] = set
            end

            -- Test
            local matchcount = 0
            for _, pos in ipairs(coords) do
                local p2s = pos2str(pos)
                if set:has(p2s) then
                    matchcount = matchcount + 1
                end
            end

            if #coords == matchcount then
                -- Exact match
                return t.name
            end
        end
    end

    return nil
end

return shapeRenamer
