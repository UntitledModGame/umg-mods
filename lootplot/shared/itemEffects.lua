---@generic T
---@param ent Entity
---@param val T|fun(ent:Entity):T
---@return T
local function getValue(ent, val)
    if type(val) == "function" then
        return val(ent)
    end

    return val
end

umg.answer("properties:getPropertyMultiplier", function(itemEnt, prop)
    local slotEnt = lp.itemToSlot(itemEnt)

    if slotEnt and slotEnt.itemNumberEffects and slotEnt.itemNumberEffects[prop] then
        return getValue(slotEnt, slotEnt.itemNumberEffects[prop].multiplier or 1)
    end

    return 1
end)

umg.answer("properties:getPropertyModifier", function(itemEnt, prop)
    local slotEnt = lp.itemToSlot(itemEnt)

    if slotEnt and slotEnt.itemNumberEffects and slotEnt.itemNumberEffects[prop] then
        return getValue(slotEnt, slotEnt.itemNumberEffects[prop].modifier or 0)
    end

    return 0
end)

-- The behavior for the boolean item effects are as follows:
-- * If the property is true, it _may_ be true.
-- * But if the property is false, the property is false as a whole.
-- Example:
-- .itemBooleanEffect = {
--     canMove = function(ent)
--         if COND then 
--           return true -- canBeTrue -> true, isFalse -> false
--         else
--           return false -- isFalse -> true, canBeTrue -> false
--         end
--     end
-- }

---@param slotEnt lootplot.SlotEntity
---@param prop string
local function evalBoolProp(slotEnt, prop)
    if slotEnt.itemBooleanEffects then
        return getValue(slotEnt, slotEnt.itemBooleanEffects[prop] or false)
    end

    return false
end

umg.answer("properties:getBooleanPropertyValue", function(itemEnt, prop)
    if lp.isItemEntity(itemEnt) then
        local slotEnt = lp.itemToSlot(itemEnt)
        return slotEnt and evalBoolProp(slotEnt, prop)
    end

    return true
end)
