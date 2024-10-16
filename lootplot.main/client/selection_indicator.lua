



local PRIO_MOUSE = 10
umg.answer("lootplot:getItemTargetPosition", function(itemEnt)
    local selection = lp.getCurrentSelection()
    local selectedItem = selection and lp.posToItem(selection.ppos)
    if itemEnt == selectedItem then
        if lp.canPlayerAccess(itemEnt, client.getClient()) then
            local camera = camera.get()
            local tx,ty = camera:toWorldCoords(input.getPointerPosition())
            return tx,ty, PRIO_MOUSE
        end
    end
end)

local PRIO_LOCK = 6
umg.answer("lootplot:getItemTargetPosition", function(itemEnt)
    if itemEnt.targetPositionLock then
        local tpl = itemEnt.targetPositionLock
        if tpl.endTime > love.timer.getTime() then
            itemEnt:removeComponent("targetPositionLock")
        end
        return tpl.x, tpl.y, PRIO_LOCK
    end
end)



local DURATION = 0.4

local function applyLerpLock(ent, targX, targY)
    --[[
    locks the ent at the current position.
    The reason we need this is because the server updated ppos is going
    to be delayed; so as a hack fix, we lock the ent in place early.
    (It expires after DURATION seconds in the event that the move failed)
    ]]
    ent.targetPositionLock = {
        endTime = love.timer.getTime() + DURATION,
        x = targX,
        y = targY
    } 
end

umg.on("lootplot:tryMoveItemsClient", function(slot1, slot2)
    local item = lp.slotToItem(slot1)
    local dvec = lp.getPos(slot2):getWorldPos()
    local targX, targY = dvec.x, dvec.y
    if item then
        applyLerpLock(item, targX, targY)
    end
end)



local CAN_MOVE = 1
local CANNOT_MOVE = 2

local COLORS = {
    objects.Color.GREEN,
    objects.Color.RED
}

local lg=love.graphics


local function drawSlotIndicator(ppos, color)
    lg.push("all")
    love.graphics.setColor(color)
    local dvec = ppos:getWorldPos()
    rendering.drawImage("select", dvec.x, dvec.y)
    lg.pop()
end


umg.on("rendering:drawEffects", function(camera)
    local selection = lp.getCurrentSelection()
    if not selection then
        return
    end

    local selectedSlot = selection.slot
    local selectedItem = lp.slotToItem(selectedSlot)

    if (not selectedItem) or (not lp.canPlayerAccess(selectedItem, client.getClient())) then
        -- cannot access item!
        return
    end

    ---@cast selectedItem Entity
    ---@cast selectedSlot Entity
    local state = nil

    local slotHover = lp.getHoveredSlot()
    local hoveredSlot = slotHover and slotHover.entity
    if hoveredSlot and hoveredSlot ~= selectedSlot then
        ---@cast hoveredSlot Entity
        if lp.canSwap(selectedSlot, hoveredSlot) and lp.canPlayerAccess(selectedItem, client.getClient()) then
            state = CAN_MOVE
        else
            state = CANNOT_MOVE
        end

        local ppos = lp.getPos(hoveredSlot)
        if state and ppos then
            local col = COLORS[state]
            drawSlotIndicator(ppos, col)
        end
    end
end)



umg.on("rendering:drawEntity", 10, function(ent)
    local selected = lp.getCurrentSelection()
    if selected and ent == selected.slot then
        drawSlotIndicator(selected.ppos, objects.Color.WHITE)
    end
end)
