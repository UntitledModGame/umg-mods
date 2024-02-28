

local h = {}



function h.itemsAreSame(item1, item2)
    --[[
        returns true/false,
        whether items are the same type.
    ]]
    return item1:type() == item2:type()
end




function h.canCombineStacks(item1, item2, count)
    -- Returns true if item1 can be combined into item2.
    -- false otherwise.
    count = (count or item1.stackSize) or 1
    -- `count` is the number of items that we want to add. (defaults to the full stackSize of item)

    if not h.itemsAreSame(item1, item2) then
        return false
    end

    local remainingStackSize = (item1.maxStackSize or 1) - count
    if (remainingStackSize < count) then
        return false -- not enough stack space to combine
    end

    return true
end





return h
