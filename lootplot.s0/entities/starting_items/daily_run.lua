

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




---@alias lootplot.s0.daily.ShopLayout {food:[lootplot.PPos],normal:[lootplot.PPos],reroll:[lootplot.PPos]}


---@param ppos lootplot.PPos
---@param rgen love.RandomGenerator
---@return lootplot.s0.daily.ShopLayout
local function getShopLayout(ppos, rgen)
    local arr = objects.Array()

    -- The structure seen with most starting-items
    for j=-1, 1, 2 do
        arr:add({
            normal = genSlots(ppos, 0,0, 3,1),
            food = genSlots(ppos, j,2, 1,2),
            reroll = genSlots(ppos, 0,-1, 1,1),
        })
    end

    arr:add({
        normal = {ppos:move(-1,-1), ppos:move(1,-1)},
        food = {ppos:move(-1,1), ppos:move(1,1)},
        reroll = {ppos}
    })

    -- No food-shop slots
    for j=-1, 1, 2 do
        arr:add({
            normal = {ppos, ppos:move(1,0), ppos:move(-1,0), ppos:move(0,-1)},
            food = {},
            reroll = genSlots(ppos, 0,j, 1,1),
        })
    end

    -- 1 food-shop, 3 normal
    for j=-1, 1, 2 do
        arr:add({
            normal = {ppos:move(0,-j), ppos:move(1,-j), ppos:move(-1,-j)},
            food = {ppos},
            reroll = genSlots(ppos, 0,j, 1,1),
        })
    end

    -- 3-reroll-slots, 1 food, 2 normal
    arr:add({
        normal = genSlots(ppos, 0,1, 2,1),
        food = genSlots(ppos, 1,1, 1,1),
        reroll = {ppos:move(-1,0), ppos:move(1,0)},
    })

    -- reroll-slot, 1 food, 2 normal
    arr:add({
        normal = genSlots(ppos, 1,-1, 2,1),
        food = genSlots(ppos, 1,1, 1,1),
        reroll = {ppos:move(-1,0), ppos:move(1,0)},
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
---@return {pulse:lootplot.PPos, main:lootplot.PPos, shop:lootplot.s0.daily.ShopLayout, sell:lootplot.PPos, special:lootplot.PPos}
local function generateLayout(plot, seed)
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

    local shop = getShopLayout(shopCenter, rgen)

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



---@param e Entity the slot-ent to be modified
---@param rgen love.RandomGenerator
---@param normalChance? number The chance that the slot should be left unchanged.
local function mutateRandomly(e, rgen, normalChance)
    normalChance = normalChance or 0
    local MAX_PROB = 0.65
    local SCALE = (MAX_PROB + (normalChance*MAX_PROB))
    local r = rgen:random() * SCALE
    local r2 = rgen:random() * SCALE

    if r < 0.1 then
        lp.modifierBuff(e, "bonusGenerated", -4)
    elseif r < 0.2 then
        lp.modifierBuff(e, "bonusGenerated", 6)
    elseif r < 0.3 then
        lp.modifierBuff(e, "multGenerated", 1)
    elseif r < 0.4 then
        lp.modifierBuff(e, "moneyGenerated", -0.3)
    elseif r < 0.5 then
        lp.modifierBuff(e, "multGenerated", -0.3)
    elseif r < 0.6 then
        lp.modifierBuff(e, "pointsGenerated", 50)
    elseif r < MAX_PROB then
        lp.modifierBuff(e, "moneyGenerated", 0.4)
    end

    if (not e.buttonSlot) and r2 < 0.3 then
        e.doomCount = rgen:random(20,30)
    end
end




local fillShop
local fillMain
local fillSell
local fillSpecial


do

---@type generation.Generator
local normalShop

umg.on("@load", function()
    if server then
        normalShop = generation.Generator()
            :add(server.entities.shop_slot, 2)
            :add(server.entities.purple_shop_slot, 0.2)
            :add(server.entities.pink_shop_slot, 0.3)
            :add(server.entities.emerald_shop_slot, 0.3)
    end
end)


---@param shop lootplot.s0.daily.ShopLayout
function fillShop(shop, team, seed)
    local rgen = love.math.newRandomGenerator(seed)

    for _, pp in ipairs(shop.normal) do
        local etype = normalShop:query()
        local e = lp.forceSpawnSlot(pp, etype, team)
        if e then mutateRandomly(e, rgen, 0.6) end
    end
    for _, pp in ipairs(shop.reroll) do
        local e = lp.forceSpawnSlot(pp, server.entities.reroll_button_slot, team)
        if e then mutateRandomly(e, rgen, 0.8) end
    end
    for _, pp in ipairs(shop.food) do
        local e = lp.forceSpawnSlot(pp, server.entities.food_shop_slot, team)
        if e then mutateRandomly(e, rgen, 0.7) end
    end
end
end





do

local exoticSlots, normalSlots

if server then
umg.on("@load", 10, function()
    local ents = server.entities
    exoticSlots = generation.Generator()
        :add(ents.cat_slot, 0.3)
        :add(ents.rulebender_slot, 0.3)
        :add(ents.pink_slot, 0.4)
        :add(ents.diamond_slot, 0.4)
        :add(ents.ruby_slot, 0.4)
        :add(ents.sapphire_slot, 0.4)
        :add(ents.purple_slot, 0.4)
        :add(ents.invincibility_slot, 0.4)
        :add(ents.emerald_slot, 0.4)
        :add(ents.rotate_slot, 0.4)
        :add(ents.level_cloth_slot, 0.4)
        :add(ents.key_cloth_slot, 0.4)
        :add(ents.swashbuckler_slot, 0.4)

    normalSlots = generation.Generator()
        :add(ents.slot, 1.3)
        :add(ents.dirt_slot, 0.4)
        :add(ents.gravel_slot, 0.5)
        :add(ents.glass_slot, 0.3)
        :add(ents.red_glass_slot, 0.05)
        :add(ents.emerald_slot, 0.05)
        :add(ents.sapphire_slot, 0.03)
end)
end



---@param centerPPos lootplot.PPos
---@param sprawlX number
---@param sprawlY number
---@param numPPoses number
---@param rgen love.RandomGenerator
---@return lootplot.PPos[]
local function sprawlPPoses(centerPPos, sprawlX, sprawlY, numPPoses, rgen)
    local pposes = objects.Array()
    assert(numPPoses <= ((sprawlX+1)*2 * (sprawlY+1)*2), "not enough area!")
    for dx=-sprawlX,sprawlX do
        for dy=-sprawlY,sprawlY do
            pposes:add(centerPPos:move(dx,dy))
        end
    end
    table.shuffle(pposes, rgen)
    local ret = objects.Array()
    for i=1, numPPoses do
        ret:add(pposes[i])
    end
    return ret
end




function fillMain(ppos, team, seed)
    local rgen = love.math.newRandomGenerator(seed)

    local r = rgen:random()
    if false and r < 0.1 then
        -- single-slot in middle
        local etype = exoticSlots:query()
        lp.forceSpawnSlot(ppos, etype, team)
    else
        -- "scattered" 3x3 normal island
        local NUM_NORMAL_SLOTS = math.floor(4 + rgen:random() * 3)
        for i, pp in ipairs(sprawlPPoses(ppos, 2, 1, NUM_NORMAL_SLOTS, rgen)) do
            local etype = normalSlots:query()
            local e = lp.forceSpawnSlot(pp, etype, team)
            mutateRandomly(e, rgen, 0.7)
        end
    end
end



function fillSell(ppos, team, seed)
    local rgen = love.math.newRandomGenerator(seed)
    local r = rgen:random()
    local r2 = rgen:random()
    local wg = lp.worldgen

    if r < 0.35 then
        if r2 < 0.5 then
            wg.spawnSlots(ppos, server.entities.sell_slot, 3,1, team)
        else
            wg.spawnSlots(ppos, server.entities.sell_slot, 1,3, team)
        end
    elseif r < 0.7 then
        local e = lp.forceSpawnSlot(ppos, server.entities.skull_slot, team)
        if e then mutateRandomly(e, rgen) end
    else
        local e = lp.forceSpawnSlot(ppos, server.entities.sell_slot, team)
        if e then mutateRandomly(e, rgen) end
    end
end




function fillSpecial(ppos, team, seed)
    local rgen = love.math.newRandomGenerator(seed)
    local r = rgen:random()
    local wg = lp.worldgen

    if r < 0.05 then
        -- tax-slot run!
        wg.spawnSlots(ppos, server.entities.null_slot, 3,3, team, function(e)
            lp.modifierBuff(e, "moneyGenerated", -2)
            e.canGoIntoDebt = true
        end)
        lp.forceSpawnSlot(ppos, server.entities.tax_button_slot, team)
    elseif r < 0.1 then
        -- Grubby-run
        wg.spawnSlots(ppos, server.entities.null_slot, 3,3, team, function(ent)
            local pos = assert(lp.getPos(ent))
            if pos ~= ppos then
                lp.forceSpawnItem(pos, server.entities.sack_grubby, team)
            end
        end)
        lp.forceSpawnSlot(ppos, server.entities.money_limit_slot, team)
    elseif r < 0.15 then
        -- destructive-run
        wg.spawnSlots(ppos, server.entities.null_slot, 1,3, team, function(e)
            e.doomCount = 7
            lp.modifierBuff(e, "pointsGenerated", -30)
            lp.modifierBuff(e, "moneyGenerated", 2)
        end)
    elseif r < 0.2 then
        -- evil/income null-slots
        wg.spawnSlots(ppos, server.entities.null_slot, 1,3, team, function(e)
            e.doomCount = 7
            lp.modifierBuff(e, "pointsGenerated", -30)
            lp.modifierBuff(e, "moneyGenerated", 2)
        end)
    elseif r < 0.5 then
        -- random slots
        local num = rgen:random(1,2)
        local slots = sprawlPPoses(ppos, 1,1, num, rgen)
        for _, pp in ipairs(slots) do
            local etyp = exoticSlots:query()
            lp.forceSpawnSlot(pp, etyp, team)
        end
    elseif r < 0.6 then
        -- null-slots with items on them
        wg.spawnSlots(ppos, server.entities.null_slot, 3,3, team, function(ent)
            local pos = assert(lp.getPos(ent))
            local r1 = rgen:random()
            if r1 < 0.3 then
                ent.doomCount = 6
            elseif r1 < 0.5 then
                local itemType = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
                if itemType then
                    lp.forceSpawnItem(pos, itemType, team)
                end
            end
        end)
    elseif r < 0.7 then
        -- stone-slots surrouding a slot
        wg.spawnSlots(ppos, server.entities.stone_slot, 3,3, team)
        local slotType = exoticSlots:query()
        lp.forceSpawnSlot(ppos, slotType, team)
    else
        local pposes = sprawlPPoses(ppos, 1,1, 3, rgen)
        for _, pp in ipairs(pposes) do
            lp.trySpawnSlot(pp, server.entities.slot, team)
            local itemType = lp.rarities.randomItemOfRarity(lp.rarities.RARE, function(entry, weight)
                local etype = server.entities[entry]
                if etype.foodItem then
                    return 0
                end
                return 1
            end)
            local e = itemType and lp.forceSpawnItem(pp, itemType, team)
            if e then
                e.stuck = true
            end
        end
    end
end


end



function daily.generate(plot, team, seed, difficulty)
    local cSeed = seed + difficulty
    local layout = generateLayout(plot, cSeed)

    fillMain(layout.main, team, seed)

    fillShop(layout.shop, team, seed)

    fillSpecial(layout.special, team, seed)

    fillSell(layout.sell, team, seed)

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
        lp.queue(plot:getCenterPPos(), function ()
            local r = love.math.random(10,1000)
            daily.generate(plot, team, r, 1)
        end)
    end
})
end


return daily

