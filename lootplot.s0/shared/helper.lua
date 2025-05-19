
local constants = require("shared.constants")


---@class helper
local helper = {}




local function hasRerollTrigger(ent)
    for _,t in ipairs(ent.triggers)do
        if t == "REROLL" then
            return true
        end
    end
    return false
end


local function shouldReroll(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and hasRerollTrigger(slot) then
        return true
    end
    local item = lp.posToItem(ppos)
    if item and hasRerollTrigger(item) then
        return true
    end
end


---@param plot lootplot.Plot
function helper.rerollPlot(plot)
    lp.Bufferer()
        :all(plot)
        :filter(shouldReroll)
        :withDelay(0.05)
        :to("SLOT_OR_ITEM")
        :execute(function(ppos, ent)
            lp.resetCombo(ent)
            lp.tryTriggerSlotThenItem("REROLL", ppos)
        end)
end


local loc = localization.localize




local TEXT_MAX_WIDTH = 200
---@param text string
---@param x number
---@param y number
---@param rot number
---@param sx number
---@param sy number
---@param oy number
---@param kx number
---@param ky number
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()
    local ox = TEXT_MAX_WIDTH / 2
    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(text, x + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
            end
        end
    end
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, x, y, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
end



local NICE_GREEN = objects.Color(49/255,189/255,32/255)

local function drawDelayItemNumber(ent, delayCount)
    local totActivs = (ent.totalActivationCount or 0)
    local remaining = delayCount - totActivs
    if totActivs > 0 then
        local txt,color
        local dx,dy=0,3
        if remaining <= 1 then
            txt = "[!]"
            color = NICE_GREEN
            local t = (love.timer.getTime() * 10)
            dx = 2 * math.sin(t)
        else
            txt = tostring(remaining)
            color = lp.COLORS.INFO_COLOR
        end
        love.graphics.push("all")
        love.graphics.setColor(color)
        printCenterWithOutline(txt, ent.x + dx, ent.y + dy, 0, 1,1, 20, 0, 0)
        love.graphics.pop()
    end
end


---@param numWins number
---@return function
function helper.unlockAfterWins(numWins)
    assert(type(numWins) == "number")
    return function()
        return lp.getWinCount() >= numWins
    end
end

---@return boolean
function helper.unlockAfterTutorial()
    return lp.metaprogression.getFlag("lootplot.s0:isTutorialCompleted")
end




local DELAY_DESC = localization.newInterpolator("After {lootplot:INFO_COLOR}%{count} activations{/lootplot:INFO_COLOR},\n%{delayDescription}")

function helper.defineDelayItem(id, name, etype)
    typecheck.assertKeys(etype, {
        "delayCount", "delayDescription", "delayAction"
    })
    local delayCount = etype.delayCount
    local delayDescription = loc(etype.delayDescription)
    local func = etype.delayAction

    -- dont want to pollute the etype with random shcomps for ergonomic reasons!
    etype.delayCount = nil
    etype.delayAction = nil
    etype.delayDescription = nil

    local itemType = {
        image = id,
        name = loc(name),

        description = function(ent)
            return DELAY_DESC({
                count = delayCount - (ent.totalActivationCount or 0),
                delayDescription = delayDescription
            })
        end,

        onActivate = function(ent)
            if (ent.totalActivationCount or 0) > (delayCount-1) then
                func(ent)
            end
        end,

        onDraw = function(ent)
            drawDelayItemNumber(ent, delayCount)
        end
    }

    for k,v in pairs(etype) do
        itemType[k] = v
    end
    lp.defineItem("lootplot.s0:"..id, itemType)
end



local TRANSFORM_ACTION_DESC = localization.newInterpolator("Turn into a {lootplot:INFO_COLOR}%{transformName}")

---@param id string
---@param name string
---@param etype table
function helper.defineTransformItem(id, name, etype)
    typecheck.assertKeys(etype, {
        "delayCount", "transformId", "transformName"
    })

    local tname = loc(etype.transformName)
    local transId = etype.transformId
    local transformFunc = etype.transformFunc
    local delayCount = etype.delayCount
    -- clear shcomps so (they dont exist within entity-type)
    etype.transformId = nil
    etype.transformName = nil
    etype.transformFunc = nil

    local function transform(ent)
        local ppos = lp.getPos(ent)
        local transEType = server.entities[transId]
        assert(transEType,"?")
        if ppos and transEType then
            local itemEnt = lp.forceSpawnItem(ppos, transEType, ent.lootplotTeam)
            if transformFunc and itemEnt then
                transformFunc(itemEnt)
            end
        end
    end

    etype.delayAction = transform
    etype.delayCount = delayCount
    etype.delayDescription = TRANSFORM_ACTION_DESC({
        transformName = tname
    })
    helper.defineDelayItem(id, name, etype)
end



--[[
This function will rotate an entity randomly.
useful with `init`, ie:

defItem("item", {
    init = helper.rotateRandomlyInit
})

^^^ items like this add a lot more variance and "spice" to the game.
]]
function helper.rotateRandomly(ent)
    local rot = lp.SEED:randomMisc(0,3)
    if rot ~= 0 then
        lp.rotateItem(ent, rot)
    end
end






do
local rr = lp.rarities
---@type {[1]: lootplot.rarities.Rarity, [2]: number}[]
local weights = {
    {rr.COMMON, 1.1},
    {rr.UNCOMMON, 1.3},
    {rr.RARE, 1.3},
    {rr.EPIC, 0.5},
    {rr.LEGENDARY, 0.1},
}

local slotBuffs = {
    pointsGenerated = 10,
    multGenerated = 0.2,
    bonusGenerated = 1
}
local keys = {}
for k,v in pairs(slotBuffs) do table.insert(keys, k) end

local function buffSlotRandomly(slotEnt)
    local prop = table.random(keys)
    local buffAmount = slotBuffs[prop]
    assert(buffAmount,"?? aye?")
    if lp.SEED:randomMisc() < 0.33 then
        -- 1/3 chance for the buff to be negative!
        lp.modifierBuff(slotEnt, prop, -buffAmount)
    else
        lp.modifierBuff(slotEnt, prop, buffAmount)
    end
end


---@param ppos lootplot.PPos
---@param lootplotTeam string
function helper.forceSpawnRandomSlot(ppos, lootplotTeam)
    local r = generation.pickWeighted(weights)
    local etype = lp.rarities.randomSlotOfRarity(r)
    if etype then
        local slotEnt = lp.forceSpawnSlot(ppos, etype, lootplotTeam)
        if (not slotEnt.buttonSlot) and lp.SEED:randomMisc() < 0.1 then
            slotEnt.repeatActivations = true
            -- Limit activations to 10 so its not unreasonable
            slotEnt.baseMaxActivations = math.min(10, slotEnt.baseMaxActivations or 10)
        end

        if lp.SEED:randomMisc() < 0.2 then
            slotEnt.doomCount = 8
        elseif lp.SEED:randomMisc() < 0.5 then
            buffSlotRandomly(slotEnt)
        end
        return slotEnt
    end
end

end





local function isNormalishSlot(slotEnt)
    return (not slotEnt.buttonSlot) and (not slotEnt.dontPropagateTriggerToItem)
end


---@param ppos lootplot.PPos
---@param threshold number
local function isPPosValid(ppos, threshold)
    --[[
    a candidate ppos is valid if it is `threshold` units away from normal-ish slots,
    AND if it doesnt contain any items or slots.
    ]]
    if lp.posToItem(ppos) or lp.posToSlot(ppos) then
        return false
    end
    for dx=-threshold, threshold do
        for dy=-threshold, threshold do
            local p2 = ppos:move(dx,dy)
            local slot = p2 and lp.posToSlot(p2)
            if slot and isNormalishSlot(slot) then
                return false
            end
        end
    end
    return true
end



local function iterateSpiral(x, y, radius, callback)
    local dx, dy = 1, 0
    local steps = 1
    local cx, cy = x, y

    callback(cx, cy) -- include the center point

    while steps <= radius * 2 do
        for i = 1, 2 do -- each layer has two sides of equal length
            for j = 1, steps do
                cx = cx + dx
                cy = cy + dy

                if math.abs(cx - x) <= radius and math.abs(cy - y) <= radius then
                    callback(cx, cy)
                end
            end
            -- rotate direction clockwise
            dx, dy = -dy, dx
        end
        steps = steps + 1
    end
end



local SEARCH_RADIUS = 5

---@param ppos lootplot.PPos
---@param distanceFromOtherSlots any
function helper.getEmptySpaceNear(ppos, distanceFromOtherSlots)
    local xx,yy = ppos:getCoords()
    local plot = ppos:getPlot()

    local bestPos = nil

    iterateSpiral(xx,yy, SEARCH_RADIUS, function(x,y)
        if bestPos then return end
        if not plot:isInBounds(x,y) then return end

        local pos = plot:getPPos(x, y)
        if (not lp.posToSlot(pos)) and (isPPosValid(ppos, distanceFromOtherSlots)) then
            bestPos = pos
        end
    end)

    return bestPos
end


function helper.isInfinity(x)
    local isNan = x ~= x
    local isInf = (x == math.huge) or (x == -math.huge)
    return isNan or isInf
end


function helper.getMoneyPerRound()
    local _, dInfo = lp.getDifficulty()
    if dInfo and constants.ROUND_INCOME[dInfo.difficulty] then
        return constants.ROUND_INCOME[dInfo.difficulty]
    end
    return constants.ROUND_INCOME[0]
end



---@param plot lootplot.Plot
---@param distFromCenter number The distance from center that the ppos should be
---@param distanceFromOtherSlots? number (DEFAULT = 1) The distance that the ppos must be from any normal-slots. higher number = harder to reach this ppos.
---@return lootplot.PPos?
function helper.getRandomEmptySpace(plot, distFromCenter, distanceFromOtherSlots)
    --[[
    finds the "average" position of slots/items, and returns a ppos
    that is roughly `dist` from the average position.
    ]]
    local threshold = distanceFromOtherSlots or 1
    local sumX, sumY = 0,0
    local count = 0
    plot:foreachSlot(function(ent, ppos)
        if isNormalishSlot(ent) then
            local x,y = ppos:getCoords()
            sumX = sumX + x
            sumY = sumY + y
            count = count + 1
        end
    end)

    local x,y = math.floor(sumX/count), math.floor(sumY / count)

    local pi2 = 2*math.pi
    local rad = love.math.random() * pi2
    for angle = rad, rad + pi2, 0.1 do
        local d = distFromCenter * ((love.math.random()/4) + 0.6)
        local dx, dy = d*math.sin(angle), d*math.cos(angle)
        local ppos = plot:getPPos(math.floor(x+dx), math.floor(y+dy))
        if isPPosValid(ppos, threshold) then
            return ppos
        end
    end
    return nil
end




return helper
