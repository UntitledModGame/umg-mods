local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param ppos lootplot.PPos
---@param progress number
local function renderSelectionTarget(ppos, image, progress, opacity)
    local worldPos = ppos:getWorldPos()
    local rot = (progress-1) * 3
    love.graphics.setColor(1,1,1,opacity)
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
            selectionTargets = lp.targets.getTargets(itemEnt)
        end
    end
end)




local function getTargetImage(item)
    if item.targetVisual then
        return item.targetVisual
    end
    return "target_plus"
end



local function getOpacity(item, ppos)
    if util.canTarget(item, ppos) then
        return 1
    end
    return 0.07
end



umg.on("rendering:drawEffects", function(camera)
    if selected and selectionTargets then
        local t = love.timer.getTime()

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
            
            local item = lp.posToItem(selected.ppos)
            if item then
                local img = getTargetImage(item)
                local progress = math.min(elapsedTime-fadeTime, FADE_IN) / FADE_IN
                local opacity = getOpacity(item, ppos)
                renderSelectionTarget(ppos, img, progress, opacity)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end)



require("shared.events_questions")

local LIFETIME = 0.4

umg.on("lootplot.targets:targetActivated", function (itemEnt, ppos)
    local ent = client.entities.empty()
    
    local dvec = ppos:getWorldPos()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension

    ent.color = objects.Color.RED
    ent.image = getTargetImage(itemEnt)

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

