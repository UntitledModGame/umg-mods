
--[[

devtools:

Commands for spawning slots/items.


TODO:
It would be ideal if this devtool infra existed within base `lootplot` mod...
But that's not really possible, because we don't know what plots exist;
(and we dont know HOW said plots are represented.)

]]

local runManager = require("shared.run_manager")


local function getPPos(clientId)
    local ctx = assert(lp.main.getRun())
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
            if not lp.forceSpawnItem(ppos, ctor, lp.main.PLAYER_TEAM) then
                chat.privateMessage(clientId, "Cannot spawn item.")
            end
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
        lp.forceSpawnSlot(ppos, ctor, lp.main.PLAYER_TEAM)
    end
})



chat.handleCommand("addMoney", {
    adminLevel = 120,
    arguments = {
        {name = "amount", type = "number"},
    },
    handler = function(clientId, amount)
        if not server then
            return
        end

        local run = assert(lp.main.getRun())
        lp.addMoney(run:getPlot():getOwnerEntity(), amount)
    end
})

chat.handleCommand("hesoyam", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, amount)
        if not server then
            return
        end

        local run = assert(lp.main.getRun())
        lp.addMoney(run:getPlot():getOwnerEntity(), 250000)
    end
})



chat.handleCommand("save", {
    adminLevel = 120,
    arguments = {},
    handler = function (clientId)
        if not server then
            return
        end

        if runManager.saveRun() then
            chat.privateMessage(clientId, "Run saved successfully.")
        else
            chat.privateMessage(clientId, "Unable to save run (run missing?).")
        end
    end
})

chat.handleCommand("crash", {
    adminLevel = 120,
    arguments = {},
    handler = function (clientId)
        if not server then
            return
        end
        umg.melt("manually initiated crash")
    end
})
