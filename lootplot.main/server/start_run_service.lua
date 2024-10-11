
local Run = require("shared.Run")

local startRunService = {}


local loc = localization.localize




--[[

This global, static state is REALLY BAD.
But i suspect that this code is all gonna get refactored in the future anyway.
So its "fine" for now.


]]
local starterItemEType = nil

local potentialPlayerGroup = umg.group("controllable", "x", "y")




local SELECTION_SLOT_TYPE = "lootplot.main:start_run.selection_slot"
lp.defineSlot(SELECTION_SLOT_TYPE, {
})



local START_SLOT_TYPE = "lootplot.main:start_run.start_button_slot"
lp.defineSlot(START_SLOT_TYPE, {
})



---@param midPPos lootplot.PPos
---@param team string
---@param perk string
function startRunService.spawnItemAndSlots(midPPos, team, perk)
    -- Perk item floats
    lp.forceSpawnItem(midPPos, server.entities[perk], team)
    -- Doom egg floats
    lp.forceSpawnItem(assert(midPPos:move(0, -4)), server.entities["lootplot.main:doom_egg"], team)

    lp.Bufferer()
        :all(midPPos:getPlot())
        :to("SLOT_OR_ITEM") -- ppos-->slot
        :execute(function(_ppos, slotEnt)
            lp.resetCombo(slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end


---@param team string
---@param perk string
function startRunService.startGame(team, perk)
    ---@type lootplot.main.Run
    local run = Run() -- lp.initialize has been called.
    local plot = run:getPlot()
    local midPPos = plot:getCenterPPos()

    startRunService.spawnItemAndSlots(midPPos, team, perk)

    -- Set camera to center
    for _, playerEnt in ipairs(potentialPlayerGroup) do
        if playerEnt:type() == "lootplot:player" then
            local worldPos = midPPos:getWorldPos()
            playerEnt.x = worldPos.x
            playerEnt.y = worldPos.y
            sync.syncComponent(playerEnt, "x")
            sync.syncComponent(playerEnt, "y")
            -- force client to accept position change
        end
    end
end



return startRunService
