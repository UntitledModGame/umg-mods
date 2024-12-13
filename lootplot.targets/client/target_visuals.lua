local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param ppos lootplot.PPos
---@param image string
---@param progress number
---@param color table
---@param opacity number
local function renderSelectionTarget(ppos, image, progress, color, opacity)
    local x,y = ppos:getWorldPos()
    local rot = (progress-1) * 3
    local c = color
    love.graphics.setColor(c[1],c[2],c[3],opacity)
    rendering.drawImage(image, x, y, rot, progress, progress)
end

---@type lootplot.Selected?
local selected
---@type objects.Array?
local selectionTargets
---@type lootplot.targets.ShapeData
local seenShape

---@param s lootplot.Selected?
umg.on("lootplot:selectionChanged", function(s)
    selected = s

    if s then
        local itemEnt = lp.posToItem(s.ppos)

        if itemEnt then
            selectionTargets = lp.targets.getShapePositions(itemEnt)
            seenShape = itemEnt.shape
        end
    end
end)


local function getXY(ppos)
    if ppos.xyCoord then
        return ppos.xyCoord.x, ppos.xyCoord.y
    end
end

local function drawBorder(ppos, image, dx, dy, rot, progress)
    local x,y = ppos:getWorldPos()
    local rot = math.rad(rot)
    rendering.drawImage(image, x+dx, y+dy, rot, progress, progress)
end

local border_image = "border_active"
local border_corner_image = "border_corner" -- corners for the insides when adjacent targerts are nil
local border_corner_out_image = "border_corner_out" -- corners for outward when adjacent targerts exist

---@param item Entity
---@param image string
---@param imageInactive string
---@param color objects.Color
---@param canInteract fun(e:Entity, p:lootplot.PPos):boolean
local function drawTargets(item, image, imageInactive, color, canInteract)
    love.graphics.setColor(1,1,1)
    local t = love.timer.getTime()
    if item.shape and seenShape ~= item.shape then
        -- ah! Shape was changed during selection. Update it.
        selectionTargets = lp.targets.getShapePositions(item)
        seenShape = item.shape
    end

    assert(selectionTargets)
    assert(selected)

    -- sort targets with target[x][y]
    local XYindexedTarget = {}
    for _, ppos in ipairs(selectionTargets) do
        local plot = ppos:getPlot()
        local x, y = plot:indexToCoords(ppos.slot)
        if XYindexedTarget[x] == nil then
            XYindexedTarget[x] = {}
        end
        XYindexedTarget[x][y] = ppos

        ppos.xyCoord = {x=x, y=y}
    end

    for _, ppos in ipairs(selectionTargets) do
        local dist = util.chebyshevDistance(selected.ppos:getDifference(ppos))
        local elapsedTime = t - selected.time
        local showTime = dist * DELAY_PER_UNIT
        local fadeTime = showTime - FADE_IN

        if elapsedTime < fadeTime then
            -- Assume selected.targets is sorted by their Chebyshev distance
            -- so we're not interested on the next item.
            break
        end
        
        local progress = math.min(elapsedTime-fadeTime, FADE_IN) / FADE_IN

        if canInteract(item, ppos) then
            renderSelectionTarget(ppos, image, progress, color, 1)
        end


        local rotTable = {
            {-1, 0},
            {0, -1},
            {1, 0},
            {0, 1},
        }

        local x,y = getXY(ppos)
        if ppos.xyCoord and x and y then
            love.graphics.setColor(color)
            --draw borders
            for i, rotations in ipairs(rotTable) do
                if (XYindexedTarget[x+rotations[1]] == nil or XYindexedTarget[x+rotations[1]][y+rotations[2]] == nil) then
                    drawBorder(ppos, border_image, rotations[1], rotations[2], (i-1)*90, progress)
                end
            end

            --draw corner
            for i, rotations in ipairs(rotTable) do
                -- the second target, kinda like turned 90 degree
                local secondRot = rotTable[i+1] or rotTable[1]
                --inward corner, checks if adjacent target doesn't exist
                if (XYindexedTarget[x+rotations[1]] and XYindexedTarget[x+rotations[1]][y+rotations[2]]) == (XYindexedTarget[x+secondRot[1]] and XYindexedTarget[x+secondRot[1]][y+secondRot[2]])then
                    drawBorder(ppos, border_corner_image, rotations[1]+secondRot[1], rotations[2]+secondRot[2], (i-1)*90, progress)
                end
                
                --outward corner, checks if adjacent target exist and the combined XY doesn't
                if (XYindexedTarget[x+rotations[1]] and XYindexedTarget[x+rotations[1]][y+rotations[2]]) ~= nil and (XYindexedTarget[x+secondRot[1]] and XYindexedTarget[x+secondRot[1]][y+secondRot[2]]) ~= nil
                and (XYindexedTarget[x+secondRot[1]+rotations[1]] and XYindexedTarget[x+secondRot[1]+rotations[1]][y+secondRot[2]+rotations[2]]) == nil then
                    drawBorder(ppos, border_corner_out_image, rotations[1]+secondRot[1], rotations[2]+secondRot[2], (i-1)*90, progress)
                end
            end

            ppos.xyCoord = nil
        end
    end
    love.graphics.setColor(1, 1, 1)
end


umg.on("rendering:drawEffects", function(camera)
    if not (selected and selectionTargets) then
        return
    end
    local item = lp.posToItem(selected.ppos)
    if not (item) then
        return
    end

    local color = lp.targets.TARGET_COLOR
    if item.listen then
        color = lp.COLORS.LISTEN_COLOR
    end

    local img = "target_plus"
    local img2 = "target_plus_inactive"
    if item.target then
        drawTargets(item, img, img2, color, util.canTarget)
    end
    if item.listen then
        drawTargets(item, img, img2, color, util.canListen)
    end
end)



require("shared.events_questions")

local LIFETIME = 0.5

umg.on("lootplot.targets:targetActivated", function (itemEnt, ppos)
    local ent = client.entities.empty()
    
    local targX, targY = ppos:getWorldPos()
    ent.x,ent.y, ent.dimension = itemEnt.x, itemEnt.y, itemEnt.dimension
    ent.targetX, ent.targetY = targX, targY

    ent.color = objects.Color.RED
    ent.image = "target_plus_active"

    --[[
        TODO:
        This is terrible!
        We shouldn't be using this component here.
        This component belongs to the lootplot.juice mod; 
        NOT lp.targets mod!!!
        Should we specify lp.juice as a dependency?
        Not sure if I am happy with that.
    ]]
    ent.joltJuice = {freq = 2, amp = math.rad(20), start = love.timer.getTime(), duration = 0.4}

    ent.lifetime = LIFETIME
    -- ^^^ delete self after X seconds
end)


