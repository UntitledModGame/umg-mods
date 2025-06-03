

local daily = {}


---@param ppos lootplot.PPos
---@param w number
---@param h number
local function genSlots(ppos, x,y, w, h)
    local arr = objects.Array()
    ppos = assert(ppos:move(x,y))
    for dx=math.floor(-w/2 + 0.5), math.floor(w/2 + 0.5)-1 do
        for dy=math.floor(-h/2 + 0.5), math.floor(h/2 + 0.5)-1 do
            local p2 = assert(ppos:move(dx,dy))
            arr:add(p2)
        end
    end
    return arr
end



---@param ppos lootplot.PPos
---@param rgen love.RandomGenerator
local function getShopStructure(ppos, rgen)
    local arr = objects.Array()

    -- The structure seen with most starting-items
    for j=-1, 1, 2 do
        arr:add({
            normal = genSlots(ppos, 0,0, 3,1),
            food = genSlots(ppos, j,2, 1,2),
            reroll = genSlots(ppos, 0,-1, 1,1),
        })
    end

    -- No food-shop slots
    for j=-1, 1, 2 do
        arr:add({
            normal = genSlots(ppos, 0,0, 5,1),
            food = {},
            reroll = genSlots(ppos, 0,j, 1,1),
        })
    end

    -- 3-reroll-slots, 1 food, 2 normal
    arr:add({
        normal = genSlots(ppos, 0,1, 2,1),
        food = genSlots(ppos, 1,1, 1,1),
        reroll = genSlots(ppos, 0,0, 3,1),
    })

    -- reroll-slot, 1 food, 2 normal
    arr:add({
        normal = genSlots(ppos, 1,-1, 2,1),
        food = genSlots(ppos, 1,1, 1,1),
        reroll = genSlots(ppos, 0,0, 3,1),
    })

    -- reroll-slot surrounded by shop
    arr:add({
        normal = {ppos:move(-1, 0), ppos:move(0,-1), ppos:move(1,0)},
        food = {ppos:move(1,1), ppos:move(-1,1)},
        reroll = genSlots(ppos, 0,0, 1,1),
    })

    -- reroll-slot surrounded by shop 2
    arr:add({
        normal = genSlots(ppos, 0,-1, 3,1),
        food = {ppos:move(1,1), ppos:move(-1,1)},
        reroll = genSlots(ppos, 0,0, 1,1),
    })

    -- square shop
    arr:add({
        normal = genSlots(ppos, 0,0, 1,2),
        food = genSlots(ppos, 1,0, 1,2),
        reroll = genSlots(ppos, -1,0, 1,1),
    })

    return table.random(arr, rgen)
end



---@param plot lootplot.Plot
---@param seed number
---@return {pulse:lootplot.PPos, main:lootplot.PPos, shop:{food:[lootplot.PPos],normal:[lootplot.PPos],reroll:[lootplot.PPos]}, sell:lootplot.PPos, special:lootplot.PPos}
local function generateLayout(plot, seed)
    --[[
    
    ]]
    local rgen = love.math.newRandomGenerator(seed)
    local cpos = plot:getCenterPPos()

    local OFFSET = 4
    local t = objects.Array({-OFFSET,0,OFFSET})
        :map(function(x)
            return assert(cpos:move(x, 0))
        end)
    table.shuffle(t, rgen)

    local main, shopCenter, special = t[1], t[2], t[3]

    local SOLO_DX = 4
    local SOLO_Y = 4

    local shouldTranspose = rgen:random() < 0.5

    ---@param ppos lootplot.PPos
    local function tryTranspose(ppos)
        if shouldTranspose then
            local x,y = ppos:getCoords()
            local cx, cy = ppos:getPlot():getCenterPPos():getCoords()
            local normX, normY = x-cx, y-cy -- normalize
            local normXT, normYT = normY, normX -- transpose
            local xT, yT = normXT+cx, normYT+cy -- convert back
            return plot:getPPos(xT,yT)
        end
        return ppos
    end

    local function transposeArray(arr)
        return objects.Array(arr):map(tryTranspose)
    end

    local shop = getShopStructure(shopCenter, rgen)

    return {
        main =  tryTranspose(main),
        special = tryTranspose(special),

        shop = {
            normal = transposeArray(shop.normal),
            food = transposeArray(shop.food),
            reroll = transposeArray(shop.reroll),
        },

        sell = tryTranspose(assert(cpos:move(rgen:random(-SOLO_DX, SOLO_DX), SOLO_Y))),
        pulse = tryTranspose(assert(cpos:move(rgen:random(-SOLO_DX, SOLO_DX), -SOLO_Y))),
    }
end



function daily.generate(plot, team, seed, difficulty)
    local cSeed = seed + difficulty
    local layout = generateLayout(plot, cSeed)

    local wg = lp.worldgen
    wg.spawnSlots(layout.main, server.entities.slot, 3,3, team)

    lp.forceSpawnSlot(layout.special, server.entities.null_slot, team)

    do
    local shop = layout.shop
    for _, pp in ipairs(shop.normal) do
        lp.forceSpawnSlot(pp, server.entities.shop_slot, team)
    end
    for _, pp in ipairs(shop.reroll) do
        lp.forceSpawnSlot(pp, server.entities.reroll_button_slot, team)
    end
    for _, pp in ipairs(shop.food) do
        lp.forceSpawnSlot(pp, server.entities.food_shop_slot, team)
    end
    end

    lp.forceSpawnSlot(layout.sell, server.entities.sell_slot, team)

    lp.forceSpawnSlot(layout.pulse, server.entities.pulse_button_slot, team)
    lp.forceSpawnSlot(assert(layout.pulse:move(1,0)), server.entities.next_level_button_slot, team)
end



if server then
chat.handleCommand("r", {
    adminLevel = 120,
    arguments = {},
    handler = function(clientId)
        local plot = lp.singleplayer.getRun():getPlot()
        local team = lp.getPlayerTeam(clientId)
        plot:foreachLayerEntry(function(ent, ppos, layer)
            ent:delete()
        end)
        daily.generate(plot, team, love.math.random(10,1000), 1)
    end
})
end


return daily

