
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
    name = loc("Selection Slot"),

    triggers = {},

    actionButtons = {
        action = function(ent, clientId)
            starterItemEType = ent
        end,
        text = loc("Choose"),
        color = objects.Color.DARK_CYAN
    },
})



local START_SLOT_TYPE = "lootplot.main:start_run.start_button_slot"
lp.defineSlot(START_SLOT_TYPE, {
    name = loc("Start Game!"),
    description = loc("Click to start the game!"),

    image = "level_button_up",
    activateAnimation = {
        activate = "level_button_hold",
        idle = "level_button_up",
        duration = 0.25
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            startRunService.startGame(ppos, ent.lootplotTeam)
        end
    end,
})




function startRunService.spawnMenuSlots(ppos, team)
    lp.forceSpawnSlot(ppos:move(0,-4), server.entities[START_SLOT_TYPE], team)

    local lpm = lp.metaprogression
    local items = objects.Array(lp.worldgen.STARTING_ITEMS:getEntries())
    items:sortInPlace(function(etypeA, etypeB)
        -- sort by whether unlocked; then, by alphabetical.
        local a = (lpm.isEntityTypeUnlocked(etypeA) and 1 or 0)
        local b = (lpm.isEntityTypeUnlocked(etypeB) and 1 or 0)
        if a == b then
            return etypeA:getTypename() < etypeB:getTypename()
        end
        return a < b
    end)

    -- spawn perks
    local i = 1
    for dy=0, 10 do
        for dx=-2, 2 do
            local pos = ppos:move(dx,dy)
            if (not pos) or (not items[i]) then
                break
            end
            local slotEType = server.entities[SELECTION_SLOT_TYPE]
            lp.trySpawnSlot(pos, slotEType, team)
            lp.trySpawnItem(pos, items[i], team)
            i = i + 1
        end
    end
    starterItemEType = items[1]
end


---@param ppos lootplot.PPos
---@param team string
function startRunService.startGame(ppos, team)
    --[[
    STEPS:

    -- clear whole plot
    -- spawn doomclock-egg
    -- spawn perk-item
    -- IN FUTURE: spawn worldgen item(s)?
    ]]
    local plot = ppos:getPlot()
    plot:foreachLayerEntry(function(ent, _ppos, _layer)
        ent:delete()
    end)

    assert(starterItemEType,"?")
    lp.forceSpawnSlot(ppos, server.entities.slot, team)
    lp.forceSpawnItem(ppos, starterItemEType, team)

    lp.trySpawnItem(assert(ppos:move(0, -4)), server.entities.doom_egg, team)
end



return startRunService
