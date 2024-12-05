
local Run = require("shared.Run")

local startRunService = {}


local loc = localization.localize




--[[

This global, static state is REALLY BAD.
But i suspect that this code is all gonna get refactored in the future anyway.
So its "fine" for now.


]]

local potentialPlayerGroup = umg.group("controllable", "x", "y")




local SELECTION_SLOT_TYPE = "lootplot.main:start_run.selection_slot"
lp.defineSlot(SELECTION_SLOT_TYPE, {
})



local START_SLOT_TYPE = "lootplot.main:start_run.start_button_slot"
lp.defineSlot(START_SLOT_TYPE, {
})



local function hasRerollTrigger(ent)
    for _,t in ipairs(ent.triggers)do
        if t == "REROLL" then
            return true
        end
    end
    return false
end

---@param ppos lootplot.PPos
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

local function fogFilter(ppos)
    local plot = ppos:getPlot()
    return plot:isFogRevealed(ppos, lp.main.PLAYER_TEAM)
end

---@param plot lootplot.Plot
---@param ppos lootplot.PPos
---@param team string
---@param radius integer
local function circularFogClear(plot, ppos, team, radius)
    local rsq = radius * radius

    for y = -radius, radius do
        for x = -radius, radius do
            local newPPos = ppos:move(x, y)

            if newPPos then
                local sq = x * x + y * y
                if sq <= rsq then
                    plot:setFogRevealed(newPPos, team, true)
                end
            end
        end
    end
end

---@param midPPos lootplot.PPos
---@param team string
---@param perk string
---@param wgen string
function startRunService.spawnItemAndSlots(midPPos, team, perk, wgen)
    local plot = midPPos:getPlot()
    -- Hide all fog by default
    plot:foreach(function(ppos)
        plot:setFogRevealed(ppos, lp.main.PLAYER_TEAM, false)
    end)
    -- Clear circle center
    circularFogClear(plot, midPPos, lp.main.PLAYER_TEAM, 4)
    assert(plot:isFogRevealed(midPPos, lp.main.PLAYER_TEAM))

    -- Perk item floats
    lp.forceSpawnItem(midPPos, server.entities[perk], team)
    -- Doom egg floats
    lp.forceSpawnItem(assert(midPPos:move(0, -4)), server.entities["lootplot.main:doom_egg"], team)
    -- Worldgen item must be next to doom egg so proper culling works.
    local worldgenPPos = assert(midPPos:move(1, -4))
    plot:setFogRevealed(worldgenPPos, lp.main.PLAYER_TEAM, true)
    lp.forceSpawnItem(worldgenPPos, server.entities[wgen], team)


    scheduling.delay(0.1, function()
        lp.queue(midPPos, function()
            -- This will be executed AFTER "SLOT_OR_ITEM" bufferer code finishes.
            lp.Bufferer()
                :all(plot)
                :filter(shouldReroll)
                :to("SLOT")
                :execute(function(ppos, ent)
                    lp.resetCombo(ent)
                    lp.tryTriggerEntity("REROLL", ent)
                end)
        end)

        lp.Bufferer()
            :all(plot)
            :filter(fogFilter)
            :to("SLOT_OR_ITEM") -- ppos-->slot
            :execute(function(_ppos, slotEnt)
                lp.resetCombo(slotEnt)
                lp.tryTriggerEntity("PULSE", slotEnt)
            end)
    end)
end



---@param ppos lootplot.PPos
local function setPlayerCamToPPos(ppos)
    for _, playerEnt in ipairs(potentialPlayerGroup) do
        if playerEnt:type() == "lootplot:player" then
            playerEnt.x, playerEnt.y = ppos:getWorldPos()
            sync.syncComponent(playerEnt, "x")
            sync.syncComponent(playerEnt, "y")
            -- force client to accept position change
        end
    end
end


---@param team string
---@param perk string
---@param wgen string
function startRunService.startGame(team, perk, wgen)
    ---@type lootplot.main.Run
    local run = Run(perk) -- lp.initialize has been called.
    local plot = run:getPlot()
    local midPPos = plot:getCenterPPos()

    startRunService.spawnItemAndSlots(midPPos, team, perk, wgen)

    -- Set camera to center
    setPlayerCamToPPos(midPPos)
end

---@param serRun string
---@param rngState lootplot.LootplotSeedSerialized
function startRunService.continueGame(serRun, rngState)
    local run = Run.deserialize(serRun)
    local plot = run:getPlot()
    local midPPos = plot:getCenterPPos()

    lp.SEED:deserializeFromTable(rngState)

    -- Set camera to center
    setPlayerCamToPPos(midPPos)
end



return startRunService
