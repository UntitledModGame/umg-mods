



components.defineComponent("inventory", {
    type = function(inv, ent)
        if ent.inventory then
            umg.melt("Attempted to redefine inventory!!!")
        end
    end
})
