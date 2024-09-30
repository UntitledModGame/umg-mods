
-- actionButtons component
--[[


PLANNING:

ent.actionButtons = {
    {
        action = function(ent, clientId)
            -- runs on server ONLY.
            ...
        end,
        hasAccess = function(ent, clientId)
            return true or false
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
            client.send("lootplot:actionButtonPress", ent, index)
        end,
        canClick = function()
            if umg.exists(ent) then
                return actionButton.hasAccess(ent, client.getClient())
            end
            return false
        end,
            priority = index + PRIO
        }
    end


    if server then
        server.on("lootplot:actionButtonPress", function(clientId, ent, index)
            if not ent.actionButtons then
                return
            end
            if not lp.canPlayerAccess(ent, clientId) then
                return
        end
        local aButton = ent.actionButtons[index]
        if not aButton then
            return
        end
        if aButton.hasAccess and (not aButton.hasAccess(ent, clientId)) then
            return
        end

        aButton.action(ent, clientId)
    end)
end


local function tryPopulateActionButtons(array, ent)
    assert(client, "Only be called clientside?")
    if not lp.canPlayerAccess(ent, client.getClient()) then
        return
    end

    for i, _ in ipairs(ent.actionButtons) do
        array:add(makeActionButton(ent, i))
    end
end


if client then

-- Custom buttons:
umg.on("lootplot:populateSelectionButtons", function(array, ppos)
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt and slotEnt.actionButtons then
        tryPopulateActionButtons(array, slotEnt)
    end

    local itemEnt = lp.posToItem(ppos)
    if itemEnt and itemEnt.actionButtons then
        tryPopulateActionButtons(array, itemEnt)
    end
end)

end

