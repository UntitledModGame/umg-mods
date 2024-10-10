
local startRunService = {}


local loc = localization.localize




--[[

This global, static state is REALLY BAD.
But i suspect that this code is all gonna get refactored in the future anyway.
So its "fine" for now.


]]
local starterItemEType = nil




local SELECTION_SLOT_TYPE = "lootplot.main:start_run.selection_slot"
lp.defineSlot(SELECTION_SLOT_TYPE, {
})



local START_SLOT_TYPE = "lootplot.main:start_run.start_button_slot"
lp.defineSlot(START_SLOT_TYPE, {
})




function startRunService.spawnMenuSlots(ppos, team)
end


---@param ppos lootplot.PPos
---@param team string
function startRunService.startGame(ppos, team)
end



return startRunService
