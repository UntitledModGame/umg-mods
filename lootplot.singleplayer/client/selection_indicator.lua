



---@param itemEnt Entity
---@return boolean
local function canMoveItem(itemEnt)
    return lp.canPlayerAccess(itemEnt, client.getClient())
        and lp.canRemoveItem(itemEnt)
end



local PRIO_MOUSE = 10
umg.answer("lootplot:getItemTargetPosition", function(itemEnt)
    local selection = lp.getCurrentSelection()
    local selectedItem = selection and lp.posToItem(selection.ppos)
    if itemEnt == selectedItem and canMoveItem(itemEnt) then
        local camera = camera.get()
        local tx,ty = camera:toWorldCoords(input.getPointerPosition())
        return tx,ty, PRIO_MOUSE
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

umg.on("lootplot:tryMoveItemsClient", function(ppos1, ppos2)
    local item = lp.posToItem(ppos1)
    local targX, targY = ppos2:getWorldPos()
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
    local x,y = ppos:getWorldPos()
    rendering.drawImage("select", x,y)
    lg.pop()
end


---@param camera camera.Camera
umg.on("rendering:drawEffects", function(camera)
    local run = lp.singleplayer.getRun()
    if not run then
        return
    end

    local selection = lp.getCurrentSelection()
    if not selection then
        return
    end

    local selectedItem = selection.item
    if (not selectedItem) or (not canMoveItem(selectedItem)) then
        -- cannot access/move item!
        return
    end

    local ppos = run:getPlot():getClosestPPos(camera:toWorldCoords(input.getPointerPosition()))
    local hoveredItem = lp.posToItem(ppos)
    local canAccessHover = (not hoveredItem) or lp.canPlayerAccess(hoveredItem, client.getClient())

    local state
    if canAccessHover and lp.canSwapItems(selection.ppos, ppos) and lp.canPlayerAccess(selectedItem, client.getClient()) then
        state = CAN_MOVE
    else
        state = CANNOT_MOVE
    end

    local col = COLORS[state]
    drawSlotIndicator(ppos, col)
end)



umg.on("rendering:drawEntity", 10, function(ent)
    local selected = lp.getCurrentSelection()
    if selected and ent == selected.slot then
        drawSlotIndicator(selected.ppos, objects.Color.WHITE)
    end
end)
