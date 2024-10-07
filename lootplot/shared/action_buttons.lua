
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


local PRIO = 1000 -- we want these action buttons to appear at the RIGHT

local function makeActionButton(ent, index)
    local actionButton = ent.actionButtons[index]
    return {
        text = function()
            if umg.exists(ent) then
                local txt = actionButton.text
                if type(txt) == "function" then 
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
    if not canClick(ent, aButton, clientId) then
        return
    end

    server.unicast(clientId, "lootplot:actionButtonPressConfirmation", ent, index)
    aButton.action(ent, clientId)
end)

end
