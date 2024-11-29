
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
        if slotEnt or ctor.canItemFloat then
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



local SHAPE_LITERAL = {}

-- Add pre-defined shape from LP targets.
for _, shapeMaybe in pairs(lp.targets) do
    if type(shapeMaybe) == "table" and shapeMaybe.name and shapeMaybe.relativeCoords then
        SHAPE_LITERAL[shapeMaybe.name] = shapeMaybe
    end
end

local SHAPE_PATTERN = {
    ["KING%-(%d+)"] = lp.targets.KingShape,
    ["ROOK%-(%d+)"] = lp.targets.RookShape,
    ["BISHOP%-(%d+)"] = lp.targets.BishopShape,
    ["QUEEN%-(%d+)"] = lp.targets.QueenShape
}

---@param name string
local function getShape(name)
    if SHAPE_LITERAL[name] then
        return SHAPE_LITERAL[name]
    end

    for k, v in pairs(SHAPE_PATTERN) do
        local a1 = tonumber(name:match("^"..k.."$"))
        if a1 then
            return v(a1)
        end
    end
end

chat.handleCommand("setShape", {
    adminLevel = 120,
    arguments = {
        {name = "shapeName", type = "string"},
    },
    handler = function(clientId, shapeName)
        if not server then return end

        local ppos = getPPos(clientId)
        local itemEnt = lp.posToItem(ppos)
        if itemEnt then
            local shape = getShape(shapeName)
            if shape then
                lp.targets.setShape(itemEnt, shape)
            else
                chat.privateMessage(clientId, "Shape '"..shapeName.."' does not exist.")
            end
        else
            chat.privateMessage(clientId, "Not above item entity.")
        end
    end
})

chat.handleCommand("reveal", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, shapeName)
        if not server then return end

        local run = assert(lp.main.getRun())
        local plot = run:getPlot()
        plot:foreach(function(ppos)
            plot:setFogRevealed(ppos, lp.main.PLAYER_TEAM, true)
        end)
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

            result["__entity__"] = tostring(t)
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

-- At this point I don't know where to place this
chat.handleCommand("spawneverythingplease", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId, entId)
        if not server then return end
        local run = lp.main.getRun()
        if not run then return end

        local plot = run:getPlot()

        -- Get all item ETypes
        local allItems = lp.newItemGenerator():getEntries()
        local etypes = {}
        local rarities = {"", "UNIQUE", "MYTHIC", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}
        for _, itemname in ipairs(allItems) do
            local etype = assert(server.entities[itemname])
            local rarity = etype.rarity and etype.rarity.id or ""

            if not etypes[rarity] then
                etypes[rarity] = {}
            end

            etypes[rarity][#etypes[rarity] + 1] = itemname
        end

        local DEBUG_SLOT = server.entities["lootplot.main:debugslot"]
        local MAX_ITEMS_IN_PPOS_X = 10
        local y = -1
        for _, rarity in ipairs(rarities) do
            local x = 1

            if etypes[rarity] and #etypes[rarity] > 0 then
                print("Spawning", rarity)
                y = y + 2

                table.sort(etypes[rarity])
                for _, etypestr in ipairs(etypes[rarity]) do
                    print("test spawn", etypestr)
                    if x >= MAX_ITEMS_IN_PPOS_X then
                        y = y + 1
                        x = 1
                    end

                    local ppos = plot:getPPos(x + 5, y)
                    local slot = lp.forceSpawnSlot(ppos, DEBUG_SLOT, lp.main.PLAYER_TEAM)
                    slot.target = etypestr
                    lp.forceActivateEntity(slot)

                    x = x + 1
                end
            end
        end
    end
})
