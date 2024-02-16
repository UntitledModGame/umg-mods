

local constants = require("shared.constants")





umg.answer("items:canOpenInventory", function(ent, inventory)
    --[[
        entities can open inventories if they are public,
        and are within range in terms of position.
    ]]
    local invEnt = inventory.owner
    if invEnt.openable and invEnt.openable.public and invEnt.x and invEnt.y then
        if ent.x and ent.y then
            local dist = math.distance(ent, invEnt)
            if dist <= (invEnt.openable.distance or constants.DEFAULT_OPENABLE_DISTANCE) then
                return true
            end
        end
    end
    return false
end)


