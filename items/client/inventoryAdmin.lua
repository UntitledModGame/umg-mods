



components.defineComponent("inventory", {
    type = function(inv, ent)
        if ent.inventory then
            error("Attempted to redefine inventory!!!")
        end
    end
})
