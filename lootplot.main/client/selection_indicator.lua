local DOTTED_DISTANCE = 8
local STATE_COLORS = {objects.Color.GRAY, objects.Color.GREEN, objects.Color.RED}

local selectedSlot = nil
local selectedItem = nil
local hoveredSlot = nil

local function drawDottedIndicator(x, y)
    love.graphics.circle("line", x, y, 2)
end

-- Handles action button selection
---@param selection lootplot.Selected
umg.on("lootplot:selectionChanged", function(selection)
    selectedSlot = nil
    selectedItem = nil

    if selection then
        local itemEnt = lp.posToItem(selection.ppos)

        if itemEnt then
            selectedSlot = selection.slot
            selectedItem = itemEnt
        end
    end
end)

umg.on("lootplot:startHoverSlot", function(ent)
    hoveredSlot = ent
end)

umg.on("lootplot:endHoverSlot", function()
    hoveredSlot = nil
end)

umg.on("rendering:drawEffects", function(camera)
    if umg.exists(selectedSlot) and umg.exists(selectedItem) then
        ---@cast selectedSlot Entity
        ---@cast selectedItem Entity

        local x, y = camera:toWorldCoords(input.getPointerPosition())
        local state = 1

        if umg.exists(hoveredSlot) and hoveredSlot ~= selectedSlot then
            ---@cast hoveredSlot Entity
            x, y = hoveredSlot.x, hoveredSlot.y
            if lp.canSwap(selectedSlot, hoveredSlot) and lp.canPlayerAccess(selectedItem, client.getClient()) then
                state = 2
            else
                state = 3
            end
        end

        -- Calculate how many dots we need to draw and the distance offset
        local dist = math.distance(selectedSlot.x - x, selectedSlot.y - y)
        local ndots = math.floor(dist / DOTTED_DISTANCE)
        local angle = math.atan2(y - selectedSlot.y, x - selectedSlot.x)
        local startOffset = 0--math.abs(ndots * DOTTED_DISTANCE - dist) / 2

        love.graphics.setColor(STATE_COLORS[state])
        for i = 0, ndots do
            local dotDistance = startOffset + i * DOTTED_DISTANCE
            local dotX = math.cos(angle) * dotDistance + selectedSlot.x
            local dotY = math.sin(angle) * dotDistance + selectedSlot.y
            drawDottedIndicator(dotX, dotY)
        end
    end
end)
