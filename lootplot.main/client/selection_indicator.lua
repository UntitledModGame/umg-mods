
local selectedSlot = nil
local selectedItem = nil
local hoveredSlot = nil


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


umg.answer("lootplot:getItemTargetPosition", function(itemEnt)
    if itemEnt == selectedItem and umg.exists(selectedItem) then
        local camera = camera.get()
        local tx,ty = camera:toWorldCoords(input.getPointerPosition())
        local prio = 1
        return tx,ty, prio
    end
end)


local CAN_MOVE = 1
local CANNOT_MOVE = 2

local COLORS = {
    objects.Color.GREEN,
    objects.Color.RED
}

umg.on("rendering:drawEffects", function(camera)
    if umg.exists(selectedSlot) and umg.exists(selectedItem) then
        ---@cast selectedSlot Entity
        ---@cast selectedItem Entity

        local state = nil
        local x, y = camera:toWorldCoords(input.getPointerPosition())

        if umg.exists(hoveredSlot) and hoveredSlot ~= selectedSlot then
            ---@cast hoveredSlot Entity
            x, y = hoveredSlot.x, hoveredSlot.y
            if lp.canSwap(selectedSlot, hoveredSlot) and lp.canPlayerAccess(selectedItem, client.getClient()) then
                state = CAN_MOVE
            else
                state = CANNOT_MOVE
            end

            local ppos = lp.getPos(hoveredSlot)
            if state and ppos then
                rendering.drawImage(ppos:getWorldPos()
            end
        end
    end
end)
