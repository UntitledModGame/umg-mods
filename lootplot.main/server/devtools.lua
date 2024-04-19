
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
        local ppos = getPPos(clientId)
        local slotEnt = lp.posToSlot(ppos)
        if slotEnt then
            -- can
            local itemEnt = ctor()
            lp.attachItem(itemEnt, slotEnt)
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
        local ppos = getPPos(clientId)
        local oldSlot = lp.posToSlot(ppos)
        if oldSlot then
            oldSlot:delete()
        end
        local slotEnt = ctor()
        lp.setSlot(ppos, slotEnt)
    end
})

