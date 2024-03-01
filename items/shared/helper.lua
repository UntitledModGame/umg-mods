

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

    local remainingStackSize = (item2.maxStackSize or 1) - (item2.stackSize or 1)
    if (remainingStackSize < count) then
        return false -- not enough stack space to combine
    end

    return true
end





local moveStackCountTc = typecheck.assert("entity", "number", "entity?")

function h.getMoveStackCount(item, count, targetItem)
    moveStackCountTc(item, count, targetItem)
    --[[
        gets how many items can be moved from item to targetItem.
        (`targetItem` may be nil; in that case, we can move the whole stack.)
    ]]
    local stackSize = item.stackSize or 1
    count = math.max(0, count or stackSize)

    if targetItem then
        if not h.itemsAreSame(item, targetItem) then
            return 0 -- can't move anything; items dont match 
        end
        local targSS = targetItem.stackSize or 1
        local targMaxSS = targetItem.maxStackSize or 1
        local stacksLeft = targMaxSS - targSS
        local maxx = item.maxStackSize or 1
        return math.min(math.min(maxx, count), stacksLeft)
    else
        local maxx = item.maxStackSize or 1
        return math.min(maxx, count)
    end
end





return h
