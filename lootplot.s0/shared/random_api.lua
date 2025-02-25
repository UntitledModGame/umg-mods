

local api = {}



local function canSlotTriggerItem(slotEnt)
    -- Check if we can propagate triggers.
    return slotEnt.canSlotPropagate
end


---@param plot lootplot.Plot
---@return lootplot.PPos?
function api.getRandomSlotForItem(plot)
    --[[
    Gets a random slot that can hold items,
        AND will propagate triggers to items.

    - doesnt include null-slots, shop-slots, sell-slots etc
    - doesnt include buttonSlots
    - doesnt include dirt-slots

    (For example, null-slots, shop-slots, sell-slots are excluded)
    ]]
    local slots = objects.Array()
    plot:foreachSlot(function(slotEnt, ppos)
        slots:add(slotEnt)
    end)

    slots = slots:filter(canSlotTriggerItem)
    slots = slots:filter(function(slotEnt)
        return (not slotEnt.buttonSlot)
            and slotEnt:type() ~= "lootplot.s0:dirt_slot"
    end)

    if #slots > 0 then
        local randSlot = table.random(slots)
        return lp.getPos(randSlot)
    end
end


---@param plot lootplot.Plot
---@param distance? number
---@return lootplot.PPos?
function api.getRandomSpaceForNormalSlot(plot, distance)
    --[[
    Gets a random ppos that is within `distance` units of a normal-slot.
    (Ie a normal-slot, ruby-slot, diamond-slot, etc.)

    This is useful for:
    - spawning curse-items next to normal-slots
    - Spawning new normal-slots randomly
    ]]
    distance = distance or 1

    local slots = objects.Array()
    plot:foreachSlot(function(slotEnt, ppos)
        slots:add(slotEnt)
    end)

    slots = slots:filter(canSlotTriggerItem)

    local pposList = objects.Set()

    for _, slotEnt in ipairs(slots) do
        local ppos = lp.getPos(slotEnt)
        if ppos then
            for dx=-distance, distance, 1 do
                for dy=-distance, distance, 1 do
                    local p2 = ppos:move(dx,dy)
                    if p2 and (not lp.posToSlot(p2)) then
                        pposList:add(p2)
                    end
                end
            end
        end
    end

    if #pposList > 0 then
        return table.random(pposList)
    end
end



return api


