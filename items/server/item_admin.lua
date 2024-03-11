


local itemGroup = umg.view("stackSize")


itemGroup:onAdded(function(itemEnt)
    if not itemEnt:isSharedComponent("maxStackSize") then
        error("item entity doesn't have a .maxStackSize shcomp: " .. itemEnt:type())
    end
    if not itemEnt.stackSize then
        itemEnt.stackSize = 1
    end
end)



umg.on("@tick", function()
    for _, itemEnt in ipairs(itemGroup) do
        if itemEnt.stackSize <= 0 then
            itemEnt:delete()
        end
    end
end)


