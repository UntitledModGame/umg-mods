---@generic T
---@param slotEnt Entity
---@param itemEnt Entity
---@param val T|fun(e:Entity,e2:Entity):T
---@return T
local function getValue(slotEnt, itemEnt, val)
    if type(val) == "function" then
        return val(slotEnt, itemEnt)
    end

    return val
end

umg.answer("properties:getPropertyMultiplier", function(itemEnt, prop)
    if not lp.isItemEntity(itemEnt) then return end
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt and slotEnt.slotItemProperties then
        local props = slotEnt.slotItemProperties
        if props.multipliers and props.multipliers[prop] then
            return getValue(slotEnt, itemEnt, props.multipliers[prop]) or 1
        end
    end

    return 1
end)

umg.answer("properties:getPropertyModifier", function(itemEnt, prop)
    if not lp.isItemEntity(itemEnt) then return end
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt and slotEnt.slotItemProperties then
        local props = slotEnt.slotItemProperties
        if props.modifiers and props.modifiers[prop] then
            return getValue(slotEnt, itemEnt, props.modifiers[prop]) or 0
        end
    end

    return 0
end)
