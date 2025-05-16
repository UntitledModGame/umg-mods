
local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param x number
---@param y number
---@param image string
---@param progress number
---@param color table
---@param isActive boolean
local function renderSelectionTarget(x, y, image, imageInactive, progress, color, isActive)
    local rot = (progress-1) * 3
    local c = color
    if isActive then
        love.graphics.setColor(c[1],c[2],c[3],1)
        local xtraRot = math.sin(love.timer.getTime() * 6) / 5
        rendering.drawImage(image, x, y, rot + xtraRot, progress, progress)
    else
        love.graphics.setColor(0.8,0.15,0.12,0.65)
        rendering.drawImage(imageInactive, x, y, rot, progress, progress)
    end
end

---@type lootplot.Selected?
local selected
---@type lootplot.PPos[]?
local selectionTargets
---@type lootplot.targets.ShapeData
local seenShape

-- New variables for hover functionality
---@type Entity?
local hoveredItem
---@type lootplot.PPos[]?
local hoverTargets
---@type lootplot.targets.ShapeData?
local hoveredSeenShape
---@type number
local hoverStartTime = 0


local function invalidateHover()
    hoveredItem = nil
    hoverTargets = nil
    hoveredSeenShape = nil
end




---@param item Entity
---@param targets lootplot.PPos[]
---@param baseTime number
---@param image string
---@param imageInactive string
---@param color objects.Color
---@param canInteract fun(e:Entity, p:lootplot.PPos):boolean
local function drawTargetsFor(item, targets, baseTime, image, imageInactive, color, canInteract)
    love.graphics.setColor(1,1,1)
    local t = love.timer.getTime()
    local itemPos = lp.getPos(item)
    if not itemPos then
        return
    end
    
    for _, ppos in ipairs(targets) do
        local pX, pY = ppos:getWorldPos()
        local pbX, pbY = itemPos:getWorldPos()
        local iX, iY = item.x, item.y
        local plot = ppos:getPlot()

        local x,y = (iX + (pX - pbX)), (iY + (pY - pbY))

        local snappedPos = plot:getClosestPPos(x,y)
        local snappedX, snappedY = snappedPos:getWorldPos()

        local dist = util.chebyshevDistance(itemPos:getDifference(ppos))
        local elapsedTime = t - baseTime
        local showTime = dist * DELAY_PER_UNIT
        local fadeTime = showTime - FADE_IN

        if elapsedTime < fadeTime then
            -- Assume targets are sorted by their Chebyshev distance
            -- so we're not interested on the next item.
            break
        end

        local progress = math.min(elapsedTime-fadeTime, FADE_IN) / FADE_IN
        local isActive = canInteract(item, snappedPos)
        renderSelectionTarget(snappedX, snappedY, image, imageInactive, progress, color, isActive)
    end
    love.graphics.setColor(1, 1, 1)
end

umg.on("rendering:drawEffects", function(camera)
    -- Handle selected items
    if selected and selectionTargets then
        local item = lp.posToItem(selected.ppos)
        if item then
            if item.shape and seenShape ~= item.shape then
                -- ah! Shape was changed during selection. Update it.
                selectionTargets = assert(lp.targets.getTargets(item))
                seenShape = item.shape
            end

            if item.listen then
                local img, color = "listener_plus", lp.COLORS.LISTEN_COLOR
                local img2 = "target_invalid"
                drawTargetsFor(item, selectionTargets, selected.time, img, img2, color, util.canListen)
            end

            if item.target then
                local img, color = "target_plus", lp.targets.TARGET_COLOR
                local img2 = "target_invalid"
                drawTargetsFor(item, selectionTargets, selected.time, img, img2, color, util.canTarget)
            end
        end

        -- we dont want to overwhelm the player by drawing too many targets.
        -- If we already have an item that is selected, dont render new targets.
        return
    end
    
    -- Handle hovered items
    if hoveredItem and umg.exists(hoveredItem) and hoverTargets then
        if hoveredItem.shape and hoveredSeenShape ~= hoveredItem.shape then
            -- Shape was changed during hover. Update it.
            hoverTargets = assert(lp.targets.getTargets(hoveredItem))
            hoveredSeenShape = hoveredItem.shape
        end

        if hoveredItem.listen then
            local img, color = "listener_plus", lp.COLORS.LISTEN_COLOR
            local img2 = "target_invalid"
            drawTargetsFor(hoveredItem, hoverTargets, hoverStartTime, img, img2, color, util.canListen)
        end

        if hoveredItem.target then
            local img, color = "target_plus", lp.targets.TARGET_COLOR
            local img2 = "target_invalid"
            drawTargetsFor(hoveredItem, hoverTargets, hoverStartTime, img, img2, color, util.canTarget)
        end
    else
        invalidateHover()
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
    ent.image = "target_plus"

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

local ENT_TARGET_TYPES = {
    -- its pretty shit hardcoding this, but its "fine" i guess
    ITEM = true,
    SLOT = true,
    SLOT_OR_ITEM = true,
    ITEM_OR_SLOT = true,
    SLOT_NO_ITEM = true,
}

--[[
returns true IFF itemEnt is targetting other entities
]]
local function isTargettingEntities(itemEnt)
    if not itemEnt.shape then
        return
    end
    local target = itemEnt.target
    return target and ENT_TARGET_TYPES[target.type]
end

local dirObj = umg.getModFilesystem()

audio.defineAudioInDirectory(
    dirObj:cloneWithSubpath("assets/sfx"), {"audio:sfx"}, "lootplot.targets:"
)

local function doTargetJuice(itemEnt)
    if not isTargettingEntities(itemEnt) then
        return
    end

    local time = love.timer.getTime()

    local targList = lp.targets.getTargets(itemEnt)
    local magnitude = 1
    if #targList <= 2 then
        magnitude = 1.5 -- go HARD! 
        -- There arent many targeted ents, so we wont overwhelm player.
    elseif #targList > 8 then
        magnitude = 0.7
        -- there are many targeted ents, so tone it down.
        -- dont wanna overwhelm player.
    elseif #targList > 16 then
        magnitude = 0.35 -- tone down EXTRA!
    end

    local entList = lp.targets.getConvertedTargets(itemEnt)
    for _, targEnt in ipairs(entList) do
        --[[
            TODO: HACK: FIXME: This is terrible!
            We shouldn't be using these components here.
            They belong to the lootplot.juice mod; NOT lp.targets mod!!!
            OH WELL, not gonna fix now. We borrow from the bank of tech debt
        ]]
        local bulgeAmp = 0.6
        if lp.isSlotEntity(targEnt) then
            bulgeAmp = 0.15 -- slot bulge should be less
        end

        targEnt:addComponent("bulgeJuice", {
            start = time,
            duration = 0.35,
            amp = bulgeAmp * magnitude
        })

        targEnt:addComponent("joltJuice", {
            freq = 1.3,
            amp = math.rad(40),
            start = time,
            duration = 0.55
        })
    end

    if (#entList > 0) then
        -- dont play if we arent targetting anything.
        audio.play("lootplot.targets:target_placement_click", {
            volume = 0.56,
            pitch = 0.8
        })
    end
end

umg.on("lootplot:itemMoved", function(itemEnt, ppos1, ppos2)
    doTargetJuice(itemEnt)
    if itemEnt == hoveredItem then
        invalidateHover()
    end
end)


---@param s lootplot.Selected?
umg.on("lootplot:selectionChanged", function(s)
    selected = s

    if s then
        local itemEnt = lp.posToItem(s.ppos)

        if itemEnt then
            selectionTargets = lp.targets.getTargets(itemEnt)
            seenShape = itemEnt.shape
            doTargetJuice(itemEnt)
        end
    end
end)

umg.on("lootplot:hoverChanged", function()
    local hov = lp.getHoveredItem()
    local item = hov and hov.entity
    local ppos = item and lp.getPos(item)

    -- Only set hover data if this is a different item than the selected one
    local isSelectedItem = selected and (item ~= selected.item)

    if item and ppos and not isSelectedItem then
        hoveredItem = item
        hoverTargets = lp.targets.getTargets(item)
        hoveredSeenShape = item.shape
        hoverStartTime = love.timer.getTime()
    else
        -- Clear hover data when nothing is hovered or when the hovered item is the selected item
        invalidateHover()
    end
end)

