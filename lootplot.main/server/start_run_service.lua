
local startRunService = {}


local loc = localization.localize




--[[

This global, static state is REALLY BAD.
But i suspect that this code is all gonna get refactored in the future anyway.
So its "fine" for now.


]]
local selectedPerk = nil




lp.defineSlot("lootplot.worldgen:selection_slot", {
    name = loc("Selection Slot"),

    triggers = {},

    init = function(ent)
        ent._isSelected = false
    end,

    actionButtons = {
        action = function(ent, clientId)
            selectedPerk = ent
        end,

        canClick = function(ent, clientId)
            return true
        end,

        text = loc("Choose"),
        color = objects.Color.DARK_CYAN
    },
})


---@alias lootplot.main.SelectionSlotFamily {slots:Entity[], selected?:Entity}

---@param count integer
---@param lootplotTeam string
---@return lootplot.main.SelectionSlotFamily
local function createSelectionSlotFamily(count, lootplotTeam)
    local slots = objects.Array()

    ---@type lootplot.main.SelectionSlotFamily
    local family = {
        slots = slots,
        selected = nil
    }
    for i=1, count do
        local slotEnt = server.entities.selection_slot()
        slotEnt.lootplotTeam = lootplotTeam
        slotEnt._selectionSlotFamily = family
        slots:add(slotEnt)
    end
    return family
end



lp.defineSlot("lootplot.s0.content:reroll_button_slot", {
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
        startRunService.startGame()
    end,
})




function startRunService.spawnMenuSlots(ppos, team)
    lp.forceSpawnSlot(ppos:move(0,-4), server.entities.start_game_button, team)

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
    local selectSlots = createSelectionSlotFamily(#items, team)
    for dy=0, 10 do
        for dx=-2, 2 do
            local pos = ppos:move(dx,dy)
            if not pos then
                break
            end
            selectSlots.slots[i] = team
            lp.setSlot(pos, selectSlots.slots[i])
            lp.trySpawnItem(pos, items[i], team)
            i = i + 1
        end
    end
end



function startRunService.startGame()

end



return startRunService
