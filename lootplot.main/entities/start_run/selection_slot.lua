
local loc = localization.localize

--[[

Selection-slot:

These slots are grouped together.
When something is selected, all other slots are deselected;
except for this one. 

]]


lp.defineSlot("lootplot.worldgen:selection_slot", {
    name = loc("Selection Slot"),

    triggers = {},

    init = function(ent)
        ent._isSelected = false
    end,

    actionButtons = {
        action = function(ent, clientId)
            -- runs on server ONLY.
            ---@type lootplot.main.SelectionSlotFamily
            local family = ent._selectionSlotFamily
            if not family then
                umg.log.error("_selectionSlotFamily component must be set!")
                return
            end
            family.selected = ent
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
---@return lootplot.main.SelectionSlotFamily
local function createSelectionSlotFamily(count)
    local slots = objects.Array()

    ---@type lootplot.main.SelectionSlotFamily
    local family = {
        slots = slots,
        selected = nil
    }
    for i=1, count do
        local slotEnt = server.entities.selection_slot()
        slotEnt._selectionSlotFamily = family
        slots:add(slotEnt)
    end
    return family
end


