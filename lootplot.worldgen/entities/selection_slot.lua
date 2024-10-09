
local loc = localization.localize

--[[

Selection-slot:

These slots are grouped together.
When something is selected, all other slots are deselected;
except for this one. 
Useful for d


TODO:::
Should this really be in here????

Ehh... maybe this should be somewhere else....


]]
lp.defineSlot("lootplot.worldgen:selection_slot", {
    name = loc("Selection Slot"),

    triggers = {},

    actionButtons = {
        action = function(ent, clientId)
            -- runs on server ONLY.
        end,
        canClick = function(ent, clientId)
            return true
        end,
        text = loc("Choose"),
        color = objects.Color.DARK_CYAN
    },
})

