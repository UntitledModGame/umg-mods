
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

---@param midPPos lootplot.PPos
---@param team string
---@param perk string
function startRunService.spawnItemAndSlots(midPPos, team, perk)
    -- Perk item floats
    lp.forceSpawnItem(midPPos, server.entities[perk], team)
    -- Doom egg floats
    lp.forceSpawnItem(assert(midPPos:move(0, -4)), server.entities["lootplot.main:doom_egg"], team)

    local plot = midPPos:getPlot()

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
            local worldPos = ppos:getWorldPos()
            playerEnt.x = worldPos.x
            playerEnt.y = worldPos.y
            sync.syncComponent(playerEnt, "x")
            sync.syncComponent(playerEnt, "y")
            -- force client to accept position change
        end
    end
end


---@param team string
---@param perk string
function startRunService.startGame(team, perk)
    ---@type lootplot.main.Run
    local run = Run(perk) -- lp.initialize has been called.
    local plot = run:getPlot()
    local midPPos = plot:getCenterPPos()

    startRunService.spawnItemAndSlots(midPPos, team, perk)

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
