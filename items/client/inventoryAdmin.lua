

local inventoryGroup = umg.group("inventory")


inventoryGroup:onAdded(function(ent)
    ent.inventory.owner = ent
end)





components.defineComponent("inventory", {
    type = function(inv, ent)
        if ent.inventory then
            error("Attempted to redefine inventory!!!")
        end
    end
})
