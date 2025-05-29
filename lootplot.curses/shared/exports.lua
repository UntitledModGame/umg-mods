


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
Above: Must be spawned ABOVE y=0
Below: Must be spawned BELOW y=0
Shop: Must be spawned next to shop
]]
local SPAWN_FILTERS = {
    AIR = function(ppos)
        return not lp.posToSlot(ppos)
    end,

    LAND = function(ppos)
        return lp.posToSlot(ppos)
    end,

    ---@param ppos lootplot.PPos
    ---@return boolean
    ABOVE = function(ppos)
        local _,y = ppos:getCoords()
        return y < -1
    end,

    BELOW = function(ppos)
        local _,y = ppos:getCoords()
        return y > 1
    end,

    SHOP = function(ppos)
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



local spawnRandomCurseTc = typecheck.assert("table", "string", "number?")

--- Spawns a curse for a particular team
--- This can fail if theres no spaces for the curse
---@param plot lootplot.Plot
---@param team string
---@param randomSampler? love.RandomGenerator
---@param range number?
---@return lootplot.ItemEntity?
function lp_curses.spawnRandomCurse(plot, team, randomSampler, range)
    spawnRandomCurseTc(plot, team, range)
    range = range or 2
    -- farkkk this is weird and hacky. oh well
    randomSampler = randomSampler or love.math.newRandomGenerator(love.math.random(0,1022093))

    local curseId = table.random(spawnableCurses, randomSampler)
    local spawnFilters = curseToSpawnFilters[curseId]

    local candidates = objects.Set()
    plot:foreachSlot(function(slotEnt, ppos)
        if isNormalishSlot(slotEnt) and (plot:isFogRevealed(ppos, team)) then
            candidates:add(ppos)
            for dx=-range, range do
                for dy=-range, range do
                    local pos2 = ppos:move(dx,dy)
                    if pos2 then
                        candidates:add(pos2)
                    end
                end
            end
        end
    end)

    candidates = candidates:filter(function(ppos)
        for _,sf in ipairs(spawnFilters) do
            if not sf(ppos) then
                return false
            end
        end
        return true
    end)

    if #candidates > 0 then
        local ppos = table.random(candidates, randomSampler)
        return lp.forceSpawnItem(ppos, server.entities[curseId], team, true)
    end
    return nil
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




---Availability: Client and Server
lp.curses = lp_curses

