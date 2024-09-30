


---comment
---@param ppos lootplot.PPos
---@param func any
local function forNeighborItems(ppos, func)
    -- loops neighbor items in a KING shape
    for dx=-1,1 do
        for dy=-1,1 do
            if (dx ~= 0) and (dy ~= 0) then
                local pos2 = ppos:move(dx,dy)
                if pos2 then
                    func(pos2)
                end
            end
        end
    end
end


umg.on("lootplot:entityActivated", function(ent)
    if not lp.isItemEntity(ent) then
        return
    end

    -- Else, search for matching:
end)

