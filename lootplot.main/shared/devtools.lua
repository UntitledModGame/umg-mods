
--[[

devtools:

Commands for spawning slots/items.


TODO:
It would be ideal if this devtool infra existed within base `lootplot` mod...
But that's not really possible, because we don't know what plots exist;
(and we dont know HOW said plots are represented.)

]]

local runManager = require("shared.run_manager")


if server then

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

end -- if server


---@param t any
---@param expandtable boolean?
---@param cyclicCheck table?
---@return string|table
local function pullValues(t, expandtable, cyclicCheck)
    local vartype = type(t)
    cyclicCheck = cyclicCheck or {}

    if vartype == "table" then
        local result = {}
        if cyclicCheck[t] then
            expandtable = false
        else
            cyclicCheck[t] = true
        end

        if umg.isEntity(t) then
            ---@cast t Entity
            if not expandtable then
                return tostring(t)
            end

            local typename = t:type()
            local etype = nil

            if server then
                etype = server.entities[typename]
            else
                etype = client.entities[typename]
            end

            if not etype then
                return string.format("%q (unavailable on %s)", typename, server and "server" or "client")
            end

            for k, v in t:components() do
                local val = pullValues(v, true, cyclicCheck)
                result[string.format("%q", k)] = val
            end
        elseif expandtable then
            for k, v in pairs(t) do
                result[pullValues(k)] = pullValues(v, true, cyclicCheck)
            end
        end

        return result
    elseif vartype == "string" then
        return string.format("%q", t)
    end

    return tostring(t)
end

---@param t table
---@param indent integer?
local function prettyPrintByLine(t, indent)
    indent = indent or 1
    local tabs = string.rep("\t", indent)

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(tabs..k.." = {")
            prettyPrintByLine(v, indent + 1)
            print(tabs.."}")
        else
            print(tabs..k.." = "..v)
        end
    end
end

chat.handleCommand("debugEnt", {
    adminLevel = 120,
    arguments = {
        {name = "entity", type = "number"},
    },
    handler = function(clientId, entId)
        local ent = umg.getEntity(entId)
        if not ent then
            print("entity "..entId.." does not exist")
            return
        end

        local keyvals = pullValues(ent, true)
        print(tostring(ent))

        if type(keyvals) == "table" then
            print("{")
            prettyPrintByLine(keyvals)
            print("}")
        else
            print(keyvals)
        end

        if server then
            chat.privateMessage(clientId, "Entity "..tostring(ent).." is printed to console")
        end
    end
})



local showEntIds = false

chat.handleCommand("toggleEntIds", {
    adminLevel = 0,
    arguments = {},
    handler = function()
        showEntIds = not showEntIds
    end
})

if client then

local fonts = require("client.fonts")
local smallFont = fonts.getSmallFont()

---@param text string
---@param x number
---@param y number
---@param rot number
---@param sx number
---@param sy number
---@param oy number
---@param kx number
---@param ky number
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(
                    text,
                    smallFont,
                    x + outX / 2,
                    y + outY / 2,
                    200,
                    "center",
                    rot,
                    sx / 2,
                    sy / 2,
                    100,
                    oy,
                    kx,
                    ky
                )
            end
        end
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, smallFont, x, y, 200, "center", rot, sx / 2, sy / 2, 100, oy, kx, ky)
end

umg.on("rendering:drawEntity", 0x7fffffff, function(ent, x,y, rot, sx,sy, kx,ky)
    if showEntIds then
        if lp.isSlotEntity(ent) then
            -- Slot is drawn differently
            printCenterWithOutline(tostring(ent.id), x, y, rot, sx, sy, -18, kx, ky)
        else
            printCenterWithOutline(tostring(ent.id), x, y, rot, sx, sy, -7, kx, ky)
        end
    end
end)

end -- if client
