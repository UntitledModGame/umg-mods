
-- actionButtons component
--[[


PLANNING:

ent.actionButtons = {
    {
        action = function(ent, clientId)
            -- runs on server ONLY.
            ...
        end,
        canClick = function(ent, clientId)
            return true or false
        end,
        canDisplay = function(ent, clientId)
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



-- client --> server
umg.definePacket("lootplot:actionButtonPress", {
    typelist = {"entity", "number"}
})

-- server --> client
umg.definePacket("lootplot:actionButtonPressConfirmation", {
    typelist = {"entity", "number"}
})



local function canClick(ent, actionButton, clientId)
    if not lp.canPlayerAccess(ent, clientId) then
        return false
    end
    if actionButton.canClick and (not actionButton.canClick(ent, clientId)) then
        return false
    end
    return true
end


local function canDisplay(ent, actionButton, clientId)
    assert(client, "This should only be called client-side")
    if actionButton.canDisplay then
        return actionButton.canDisplay(ent, clientId)
    end
    return true
end


local PRIO = 1000 -- we want these action buttons to appear at the RIGHT

local function makeActionButton(ent, index)
    local actionButton = ent.actionButtons[index]
    return {
        text = function()
            if umg.exists(ent) then
                local txt = actionButton.text
                if objects.isCallable(txt) then
                    return txt(ent)
                end
                return txt or ""
            end
            return ""
        end,
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
                return canClick(ent, ent.actionButtons[index], client.getClient())
            end
        end,
        priority = index + PRIO
    }
end




local function tryPopulateActionButtons(array, ent)
    assert(client, "Only be called clientside?")
    local cl = client.getClient()
    if not lp.canPlayerAccess(ent, cl) then
        return
    end

    for i, ab in ipairs(ent.actionButtons) do
        if canDisplay(ent, ab, cl) then
            array:add(makeActionButton(ent, i))
        end
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


client.on("lootplot:actionButtonPressConfirmation", function(ent, index)
    local aButton = ent.actionButtons[index]
    aButton.action(ent, client.getClient())
end)

end




if server then

server.on("lootplot:actionButtonPress", function(clientId, ent, index)
    if not ent.actionButtons then
        return
    end
    local aButton = ent.actionButtons[index]
    if not aButton then
        return
    end
    if not umg.exists(ent) then
        return -- this can happen if the player double-clicks in one tick
    end
    if not canClick(ent, aButton, clientId) then
        return
    end

    server.unicast(clientId, "lootplot:actionButtonPressConfirmation", ent, index)
    aButton.action(ent, clientId)
end)

end
