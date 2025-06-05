


-- boolean comp, determines whether or not something is a curse.
components.defineComponent("isCurse")
-- NOTE: Items AND SLOTS can be curses!


components.defineComponent("curseCount")
-- curseCount defaults to 1 for curses.
-- If curseCount = 2, the item counts as 2 curses.
-- If curseCount = 0, the item isn't included in the count.
-- If curseCount is negative, then it decreases the curse-count!!



assert(not lp.curses, "you lil SHIT! dont overwrite my namespace")
---@class lootplot.curses
local lp_curses = {}



lp_curses.COLOR = {128/255, 17/255, 22/255}




local isCurseTc = typecheck.assert("table")

--- Checks if an entity is a curse
---@param ent_or_etype Entity
---@return boolean
function lp_curses.isCurse(ent_or_etype)
    isCurseTc(ent_or_etype)
    return ent_or_etype.isCurse
end



--[[
Within(X): Must be spawned within X units of player's basic-slots
AIR: spawn midair
LAND: spawn on land
Above: Must be spawned ABOVE stuff
Below: Must be spawned BELOW stuff
Shop: Must be spawned next to shop
]]
local SPAWN_FILTERS = {
    FLOATY = function(ppos)
        return not lp.posToSlot(ppos)
    end,

    NON_FLOATY = function(ppos)
        return lp.posToSlot(ppos)
    end,

    ---@param ppos lootplot.PPos
    ---@return boolean
    ABOVE = function(ppos)
        local midPoint = ppos:getPlot():getCenterPPos()
        local _,dy = midPoint:getDifference(ppos)
        return dy < -1
    end,

    BELOW = function(ppos)
        local midPoint = ppos:getPlot():getCenterPPos()
        local _,dy = midPoint:getDifference(ppos)
        return dy > 1
    end,

    SHOP = function(ppos)
        -- todo: this shit is untested
        do
            local p = ppos:move(-1,0)
            local slot = p and lp.posToSlot(p)
            if slot and slot:type() == "lootplot.s0:shop_slot" then
                return true
            end
        end do
            local p = ppos:move(-1,0)
            local slot = p and lp.posToSlot(p)
            if slot and slot:type() == "lootplot.s0:shop_slot" then
                return true
            end
        end do
            local p = ppos:move(-1,0)
            local slot = p and lp.posToSlot(p)
            if slot and slot:type() == "lootplot.s0:shop_slot" then
                return true
            end
        end do
            local p = ppos:move(-1,0)
            local slot = p and lp.posToSlot(p)
            if slot and slot:type() == "lootplot.s0:shop_slot" then
                return true
            end
        end
    end
}

local spawnableCurses = objects.Array()
local curseToSpawnFilters = {--[[
    [curseId] -> { spawnFilter... }
]]}



local addSpawnableCurseTc = typecheck.assert("string", "table")

function lp_curses.addSpawnableCurse(curseId, spawnFilters)
    addSpawnableCurseTc(curseId, spawnFilters)
    spawnFilters = (spawnFilters or {})
    for _,sf in ipairs(spawnFilters) do
        assert(SPAWN_FILTERS[sf], "? invalid spawnFilter")
    end
    spawnableCurses:add(curseId)
    curseToSpawnFilters[curseId] = spawnFilters
end


local function isNormalishSlot(slotEnt)
    return (not slotEnt.buttonSlot) and (not slotEnt.dontPropagateTriggerToItem)
end

local function isFogRevealed(ppos, team)
    return ppos:getPlot():isFogRevealed(ppos, team)
end

local function hasNoItem(ppos)
    return not lp.posToItem(ppos)
end




---@param plot lootplot.Plot
---@param team string
---@param randomSampler love.RandomGenerator
---@param range number
---@return objects.Set
local function getSpawnCandidates(plot, team, randomSampler, range)
    range = range or 2

    local candidates = objects.Set()
    plot:foreachSlot(function(slotEnt, ppos)
        if isNormalishSlot(slotEnt) and isFogRevealed(ppos, team) then
            if hasNoItem(ppos) then
                candidates:add(ppos)
            end
            for dx=-range, range do
                for dy=-range, range do
                    local pos2 = ppos:move(dx,dy)
                    if pos2 and (not lp.posToSlot(pos2)) and isFogRevealed(pos2, team) and hasNoItem(pos2) then
                        candidates:add(pos2)
                    end
                end
            end
        end
    end)

    return candidates
end



--- Gets a ppos for a curse to spawn on.
--- Useful if we wanna spawn our own custom-curse.
---@param plot lootplot.Plot
---@param team string
---@param isFloating boolean
---@param randomSampler? love.RandomGenerator
---@return lootplot.PPos?
function lp_curses.getPositionForCurse(plot, team, isFloating, randomSampler)
    randomSampler = randomSampler or love.math.newRandomGenerator(love.math.random(0,1022093))
    local range = 2
    local candidates = getSpawnCandidates(plot, team, randomSampler, range)

    candidates = candidates:filter(function(ppos)
        local isAir = not lp.posToSlot(ppos)
        if isFloating then
            return isAir -- then only filter air pposes
        else
            return (not isAir) -- otherwise only filter slots
        end
    end)

    if #candidates > 0 then
        return table.random(candidates, randomSampler)
    end
end



local spawnRandomCurseTc = typecheck.assert("table", "string", "love:RandomGenerator?", "number?")

--- Spawns a curse for a particular team
--- This can fail if theres no spaces for the curse
---@param plot lootplot.Plot
---@param team string
---@param randomSampler? love.RandomGenerator
---@param range number?
---@return lootplot.ItemEntity?
function lp_curses.spawnRandomCurse(plot, team, randomSampler, range)
    spawnRandomCurseTc(plot, team, randomSampler, range)
    range = range or 2
    -- farkkk this is weird and hacky. oh well
    randomSampler = randomSampler or love.math.newRandomGenerator(love.math.random(0,1022093))

    local curseId = table.random(spawnableCurses, randomSampler)
    local spawnFilters = curseToSpawnFilters[curseId]

    local candidates = getSpawnCandidates(plot, team, randomSampler, range)

    candidates = candidates:filter(function(ppos)
        for _,sf in ipairs(spawnFilters) do
            local func = SPAWN_FILTERS[sf]
            if not func(ppos) then
                return false
            end
        end
        return true
    end)

    if #candidates > 0 then
        local ppos = table.random(candidates, randomSampler)
        ---@cast ppos lootplot.PPos
        local ent = lp.forceSpawnItem(ppos, server.entities[curseId], team, true)
        return ent
    end
    return nil
end




local spawnRandomCurseAtTc = typecheck.assert("table", "string", "love:RandomGenerator?")

--- Spawns a random curse at a position
---@param ppos lootplot.PPos
---@param team string
---@param randomSampler? love.RandomGenerator
---@return lootplot.ItemEntity?
function lp_curses.spawnRandomCurseAt(ppos, team, randomSampler)
    spawnRandomCurseAtTc(ppos, team)
    local curseId = table.random(spawnableCurses, randomSampler)
    local ent = lp.forceSpawnItem(ppos, server.entities[curseId], team, true)
    return ent
end




local function teamOK(ent, team)
    return (not team) or ent.lootplotTeam == team
end

---@param plot lootplot.Plot
---@param team? string The team to check for (useful for multiplayer)
---@return number count the number of curse-items and curse-slots
function lp_curses.getCurseCount(plot, team)
    local count = 0

    plot:foreachItem(function(ent)
        if lp_curses.isCurse(ent) and teamOK(ent, team) then
            count = count + (ent.curseCount or 1)
        end
    end)
    plot:foreachSlot(function(ent)
        if lp_curses.isCurse(ent) and teamOK(ent, team) then
            count = count + (ent.curseCount or 1)
        end
    end)

    return count
end



if client then

local CURSE_TAG = localization.localize("{lootplot.curses:COLOR}CURSE{/lootplot.curses:COLOR}")
local h,s,v = objects.Color(lp_curses.COLOR):getHSV()

local CURSE_COLOR_LIGHT = objects.Color(0,0,0,1)
CURSE_COLOR_LIGHT:setHSV(h,s,v+0.25)

text.defineEffect("lootplot.curses:COLOR", function(args, char)
    char:setColor(CURSE_COLOR_LIGHT)
end)

umg.on("lootplot:populateDescriptionTags", function(ent, arr)
    if lp.curses.isCurse(ent) then
        arr:add(CURSE_TAG)
    end
end)

end



---Availability: Client and Server
lp.curses = lp_curses

