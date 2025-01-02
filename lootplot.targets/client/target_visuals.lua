local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param ppos lootplot.PPos
---@param image string
---@param progress number
---@param color table
---@param isActive boolean
local function renderSelectionTarget(ppos, image, imageInactive, progress, color, isActive)
    local x,y = ppos:getWorldPos()
    local rot = (progress-1) * 3
    local c = color
    if isActive then
        love.graphics.setColor(c[1],c[2],c[3],1)
        local xtraRot = math.sin(love.timer.getTime() * 6) / 5
        rendering.drawImage(image, x, y, rot + xtraRot, progress, progress)
    else
        love.graphics.setColor(c[1],c[2],c[3],0.55)
        rendering.drawImage(imageInactive, x, y, rot, progress, progress)
    end
end

---@type lootplot.Selected?
local selected
---@type lootplot.PPos[]?
local selectionTargets
---@type lootplot.targets.ShapeData
local seenShape

---@param s lootplot.Selected?
umg.on("lootplot:selectionChanged", function(s)
    selected = s

    if s then
        local itemEnt = lp.posToItem(s.ppos)

        if itemEnt then
            selectionTargets = lp.targets.getTargets(itemEnt)
            seenShape = itemEnt.shape
        end
    end
end)






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
        selectionTargets = lp.targets.getTargets(item)
        seenShape = item.shape
    end

    assert(selectionTargets)
    assert(selected)
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
        local isActive = canInteract(item, ppos)
        renderSelectionTarget(ppos, image, imageInactive, progress, color, isActive)
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

    if item.listen then
        local img, color = "listener_plus", lp.COLORS.LISTEN_COLOR
        local img2 = "listener_plus_inactive"
        drawTargets(item, img, img2, color, util.canListen)
    end

    if item.target then
        local img, color = "target_plus", lp.targets.TARGET_COLOR
        local img2 = "target_plus_inactive"
        drawTargets(item, img, img2, color, util.canTarget)
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


