local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param ppos lootplot.PPos
---@param image string
---@param progress number
---@param color table
---@param opacity number
local function renderSelectionTarget(ppos, image, progress, color, opacity)
    local worldPos = ppos:getWorldPos()
    local rot = (progress-1) * 3
    local c = color
    love.graphics.setColor(c[1],c[2],c[3],opacity)
    rendering.drawImage(image, worldPos.x, worldPos.y, rot, progress, progress)
end

---@type lootplot.Selected?
local selected
---@type objects.Array?
local selectionTargets

---@param s lootplot.Selected?
umg.on("lootplot:selectionChanged", function(s)
    selected = s

    if s then
        local itemEnt = lp.posToItem(s.ppos)

        if itemEnt then
            selectionTargets = lp.targets.getShapePositions(itemEnt)
        end
    end
end)




local function getOpacity(item, ppos)
    if util.canTarget(item, ppos) then
        return 1
    end
    return 0.33
end


umg.on("rendering:drawEffects", function(camera)
    if not (selected and selectionTargets) then
        return
    end
    local item = lp.posToItem(selected.ppos)
    if not (item and item.target) then
        return
    end

    local t = love.timer.getTime()

    local img, color
    if item.listen then
        img, color = "listener_plus", lp.targets.LISTEN_COLOR
    else -- its .target instead!
        img, color = "target_plus", lp.targets.TARGET_COLOR
    end

    love.graphics.setColor(1,1,1)
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
        local opacity = getOpacity(item, ppos)
        renderSelectionTarget(ppos, img, progress, color, opacity)
    end
    love.graphics.setColor(1, 1, 1)
end)



require("shared.events_questions")

local LIFETIME = 0.5

umg.on("lootplot.targets:targetActivated", function (itemEnt, ppos)
    local ent = client.entities.empty()
    
    local dvec = ppos:getWorldPos()
    ent.x,ent.y, ent.dimension = itemEnt.x, itemEnt.y, itemEnt.dimension
    ent.targetX, ent.targetY = dvec.x, dvec.y

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


