

local Inventory = require("shared.Inventory")




local inventoryGroup = umg.group("inventory")


inventoryGroup:onAdded(function(ent)
    if (not ent.inventory) or (getmetatable(ent.inventory) ~= Inventory) then
        error("Inventory component must be initialized either before entity creation, or inside a `.init` function!")
    end
    ent.inventory.owner = ent
end)





components.defineComponent("inventory", {
    type = function(inv, ent)
        if ent.inventory then
            error("Attempted to redefine inventory!!!")
        end
    end
})
