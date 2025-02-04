
local loc = localization.localize
local interp = localization.newInterpolator
local wg = lp.worldgen


local function definePerk(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float
    etype.triggers = {"PULSE"}

    id = "lootplot.s0:" .. id
    lp.defineItem(id, etype)
    lp.worldgen.STARTING_ITEMS:add(id)
end


---@param ent Entity
---@return lootplot.PPos, string
local function getPosTeam(ent)
    return assert(lp.getPos(ent)), assert(ent.lootplotTeam)
end


---@param ppos lootplot.PPos
---@param team string
---@param radius integer
local function clearFogInCircle(ppos, team, radius)
    local plot = ppos:getPlot()
    local rsq = radius * radius

    for y = -radius, radius do
        for x = -radius, radius do
            local newPPos = ppos:move(x, y)

            if newPPos then
                local sq = x * x + y * y
                if sq <= rsq then
                    plot:setFogRevealed(newPPos, team, true)
                end
            end
        end
    end
end

local function spawnDoomClock(ent)
    local plot = lp.getPos(ent):getPlot()
    local team = assert(ent.lootplotTeam)
    local ppos = assert(lp.getPos(ent)
        :move(0, -4)
    )

    local dclock = server.entities.doom_clock()
    dclock._plotX, dclock._plotY = ppos:getCoords()
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local wppos = plot:getPPos(dclock._plotX, dclock._plotY)
    dclock.x, dclock.y, dclock.dimension = wppos:getWorldPos()

    -- Clear fog around doom clock
    clearFogInCircle(ppos, team, 1)

    -- Meta-buttons
    lp.forceSpawnSlot(
        assert(ppos:move(-4,0)),
        server.entities.pulse_button_slot,
        team
    )
    lp.forceSpawnSlot(
        assert(ppos:move(-3,0)),
        server.entities.next_level_button_slot,
        team
    )
end


local function spawnShop(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(-4,0)), server.entities.shop_slot, 3,1, team)
    wg.spawnSlots(assert(ppos:move(-5,1)), server.entities.shop_slot, 1,1, team)

    wg.spawnSlots(assert(ppos:move(-3,3)), server.entities.food_shop_slot, 1,2, team)
end

local function spawnRerollButton(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(-4, -1)), server.entities.reroll_button_slot, 1,1, team)
end

local function spawnNormal(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(ppos, server.entities.slot, 3,3, team)
end

local function spawnSell(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(0, 3)), server.entities.sell_slot, 1,1, team)
end

local function spawnMoneyLimit(ent)
    local ppos, team = getPosTeam(ent)
    local plot = ppos:getPlot()
    wg.spawnSlots(plot:getPPos(ppos:getCoords(), 0), server.entities.money_limit_slot, 1,1, team)
end

local function spawnInterestSlot(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(5,-4), server.entities.interest_slot, 1,1, team))
end

-------------------------------------------------------------------

-------------------------------------------------------------------
---  Perk/starter-item definitions:
-------------------------------------------------------------------

-------------------------------------------------------------------

local MOVEMENT_TEXT = loc("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}WASD / Right click to move.\nScroll to zoom.{/outline}{/wavy}")

local OBJECTIVE_TEXT = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}{c r=1 g=0.4 b=0.3}You have {lootplot:INFO_COLOR}%{numRounds}{/lootplot:INFO_COLOR} Rounds to\nget the required points!{/outline}{/wavy}")


umg.defineEntityType("lootplot.s0:one_ball_tutorial_text", {
    lifetime = 50,
    drawDepth = 200,

    onUpdateServer = function(ent)
        local run = lp.main.getRun()
        if run and run:getAttribute("ROUND") > 1 then
            ent:delete()
        end
    end,

    onUpdateClient = function(ent)
        local run = lp.main.getRun()
        if run then
            local plot = run:getPlot()
            local ppos = plot:getPPos(ent.pposX, ent.pposY)
            ent.x, ent.y = ppos:getWorldPos()
        end
    end,
})

---@param ppos lootplot.PPos
---@param text table
local function spawnTutorialText(ppos, text)
    local textEnt = server.entities.one_ball_tutorial_text()
    textEnt.text = text
    textEnt.pposX, textEnt.pposY = ppos:getCoords()
    return textEnt
end


definePerk("one_ball", {
    name = loc("One Ball"),
    description = loc("Gain an extra $2 per turn"),

    baseMoneyGenerated = 2,
    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        spawnShop(ent)
        spawnNormal(ent)
        spawnRerollButton(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        spawnDoomClock(ent)

        -- Display tutorial text
        spawnTutorialText(assert(ppos:move(0, -3)), {
            text = OBJECTIVE_TEXT({
                numRounds = lp.main.getNumberOfRounds(ent)
            }),
            align = "center",
            oy = 10
        })

        spawnTutorialText(assert(ppos:move(0, -1)), {
            text = MOVEMENT_TEXT,
            align = "center",
            oy = 10
        })
    end
})



definePerk("five_ball", {
    name = loc("Five Ball"),
    description = loc("Starts with a rotation-slot"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        spawnDoomClock(ent)

        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.rotate_slot, 1,1, team)
    end
})




definePerk("nine_ball", {
    name = loc("Nine Ball"),
    description = loc("Has no money limit."),

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnDoomClock(ent)
    end
})




definePerk("eight_ball", {
    name = loc("Eight Ball"),
    description = loc("Starts with 3 null-slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        spawnDoomClock(ent)
        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.null_slot, 1,3, team)
    end
})



definePerk("fourteen_ball", {
    name = loc("Fourteen Ball"),
    description = loc("Spawns with 3 reroll-slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        spawnShop(ent)
        spawnRerollButton(ent)

        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.reroll_slot, 1,3, team)

        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        spawnDoomClock(ent)
    end
})




local function spawnSpecialGlassSlot(pos, team)
    local ent = lp.trySpawnSlot(pos, server.entities.glass_slot, team)
    if not ent then return end
    if lp.SEED:randomMisc() < 0.2 then
        lp.modifierBuff(ent, "pointsGenerated", 3)
    end
    if lp.SEED:randomMisc() < 0.2 then
        ent.lives = 2
    end
    if lp.SEED:randomMisc() < 0.2 then
        lp.modifierBuff(ent, "pointsGenerated", -2)
    end
    if lp.SEED:randomMisc() < 0.1 then
        ent.doomCount = 4
    end
end


definePerk("four_ball", {
    --[[
    The purpose of this item isnt really to be a "well-designed" starter item,
    but rather, it serves to provide INSPIRATION for future modded starter-items!!!
    YOU!!! PERSON READING THIS CODE!
    BE INSPIRED!!!
    (because im NGL, this item is designed very very poorly.)
    ]]
    name = loc("Four Ball"),
    description = loc("Starts with funny glass-slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnNormal(ent)
        spawnShop(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        local plot = ppos:getPlot()
        local D = 7
        local x,y = ppos:getCoords()
        plot:foreachInArea(x-D,y-D,x+D,y+D, function(pos)
            local xx,yy = pos:getCoords()
            if (xx+yy) % 2 == 0 then
                spawnSpecialGlassSlot(pos, team)
            end
        end)

        spawnDoomClock(ent)
    end
})




definePerk("bowling_ball", {
    name = loc("Bowling Ball"),
    description = loc("CHALLENGE-ITEM!\nFor PROS ONLY."),

    baseMoneyGenerated = -1,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)

        wg.spawnSlots(ppos, server.entities.slot, 1,3, team)

        local plot = ppos:getPlot()
        plot:foreachSlot(function(slotEnt, _ppos)
            slotEnt.doomCount = lp.SEED:randomMisc(40, 50)
        end)

        spawnDoomClock(ent)
    end
})


