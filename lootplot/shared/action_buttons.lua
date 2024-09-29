
-- actionButtons component
--[[


PLANNING:

ent.actionButtons = {
    {
        action = function(ent)
            -- runs on server AND client.
            ...
        end,
        text = text,
        color = color
    }, 

    {
        ...
    }
}


]]


umg.definePacket("lootplot:actionButtonPress", {
    typelist = {"entity", "number"}
})



local PRIO = 1000 -- we want these action buttons to appear at the RIGHT

local function makeActionButton(ent, index)
    local actionButton = ent.actionButtons[index]
    return {
        text = actionButton.text,
        color = actionButton.color or objects.Color.WHITE,
        onClick = function()
            if not umg.exists(ent) then
                return -- no-op
            end
            -- else, we try sync the operation
        end,
        priority = index + PRIO
    }
end


local function tryPopulateActionButtons(array, ent)
    umg.melt("NYI.")
    if not lp.canPlayerAccess(ent, client.getClient()) then
        return
    end

    for i, _ in ipairs(ent.actionButtons) do
        array:add(makeActionButton(ent, i))
    end
end


-- Custom buttons:
umg.answer("lootplot:collectSelectionButtons", function(array, ppos)
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt and slotEnt.actionButtons then
        tryPopulateActionButtons(array, slotEnt)
    end

    local itemEnt = lp.posToSlot(ppos)
    if itemEnt and itemEnt.actionButtons then
        tryPopulateActionButtons(array, itemEnt)
    end
end)


