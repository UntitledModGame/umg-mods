local util = require("shared.util")

local FADE_IN = 0.1
local DELAY_PER_UNIT = 0.04

---@param ppos lootplot.PPos
---@param progress number
local function renderSelectionTarget(ppos, progress)
    local worldPos = ppos:getWorldPos()
    local rot = (progress-1) * 3
    rendering.drawImage("target_visual", worldPos.x, worldPos.y, rot, progress, progress)
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

            renderSelectionTarget(ppos, math.min(elapsedTime-fadeTime, FADE_IN) / FADE_IN)
        end
        love.graphics.setColor(1, 1, 1)
    end
end)
