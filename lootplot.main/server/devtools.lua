
--[[

devtools:

Commands for spawning slots/items.


TODO:
It would be ideal if this devtool infra existed within base `lootplot` mod...
But that's not really possible, because we don't know what plots exist;
(and we dont know HOW said plots are represented.)

]]


local function getPPos(clientId)
    local ctx = lp.main.getContext()
    local plot = ctx:getPlot()

    local player = control.getControlledEntities(clientId)[1]
    return plot:getClosestPPos(player.x, player.y)
end


local function invalidEntityType(clientId, etype)
    chat.privateMessage(clientId, "Invalid entity type: " .. tostring(etype))
end


chat.handleCommand("spawnItem", {
    adminLevel = 120,
    arguments = {
        {name = "entityType", type = "string"},
    },
    handler = function(clientId, etype)
        if not server then
            return
        end

        local ctor = server.entities[etype]
        if not ctor then
            invalidEntityType(clientId, etype)
            return
        end
        local ppos = getPPos(clientId)
        local slotEnt = lp.posToSlot(ppos)
        if slotEnt then
            -- can
            local itemEnt = ctor()
            lp.attachItem(itemEnt, slotEnt)
        else
            chat.privateMessage(clientId, "Cannot spawn item; not over a slot.")
        end
    end
})



chat.handleCommand("spawnSlot", {
    adminLevel = 120,
    arguments = {
        {name = "entityType", type = "string"},
    },
    handler = function(clientId, etype)
        if not server then
            return
        end

        local ctor = server.entities[etype]
        if not ctor then
            invalidEntityType(clientId, etype)
            return
        end
        local ppos = getPPos(clientId)
        local oldSlot = lp.posToSlot(ppos)
        if oldSlot then
            oldSlot:delete()
        end
        local slotEnt = ctor()
        lp.setSlot(ppos, slotEnt)
    end
})


chat.handleCommand("spawnSlot", {
    adminLevel = 120,
    arguments = {},
    handler = function()
        if server then
            local ctx = lp.main.getContext()
            ctx:goNextRound()
        end
    end
})


