
local loc = localization.localize
local interp = localization.newInterpolator
local wg = lp.worldgen

local constants = require("shared.constants")

local daily = require("entities.starting_items.daily_run")


--[[
we need to make sure tutorial-cat is loaded first,
because that starting-item should be shown FIRST.
]]
require("entities.tutorial.tutorial")
-- (Since the order of `lp.worldgen.STARTING_ITEMS` matters!)



local defPerkTc = typecheck.assert("string", "table")

local function defineStartingItem(id, etype)
    defPerkTc(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float
    etype.triggers = etype.triggers or {"PULSE"}
    assert(lp.hasTrigger(etype, "PULSE"), "?")

    id = "lootplot.s0:" .. id

    lp.defineWinRecipient(id)

    lp.defineItem(id, etype)
    lp.worldgen.STARTING_ITEMS:add(id)
end


local function defineStartingItemNoDifficulty(id, etype)
    defPerkTc(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float
    etype.triggers = etype.triggers or {"PULSE"}
    assert(lp.hasTrigger(etype, "PULSE"), "?")

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
    local searchRad = math.ceil(radius)
    local plot = ppos:getPlot()
    local rsq = radius * radius

    for y = -searchRad, searchRad do
        for x = -searchRad, searchRad do
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



---@param ppos lootplot.PPos
---@param team string
---@param numActivations number
---@param numCurses number
---@return Entity?
local function spawnStoneHand(ppos, team, numActivations, numCurses)
    clearFogInCircle(ppos, team, 1.5)
    local stoneHand = lp.forceSpawnItem(ppos, server.entities.stone_hand, team, true)
    if stoneHand then
        stoneHand.stoneHand_activations = numActivations
        stoneHand.stoneHand_curses = numCurses
    end
    return stoneHand
end




local CURSE_X, CURSE_Y = 3, -4

local function spawnCurses(ent, dx,dy)
    dx = (dx or 0) + CURSE_X
    dy = (dy or 0) + CURSE_Y
    local ppos, team = getPosTeam(ent)
    local d, dInfo = lp.getDifficulty()
    if dInfo.difficulty == 1 then
        -- normal mode
        spawnStoneHand(assert(ppos:move(dx,dy)), team, 25, 3)
    elseif dInfo.difficulty >= 2 then
        -- HARD mode
        spawnStoneHand(assert(ppos:move(dx-1, dy)), team, 15, 2)

        local p2 = assert(ppos:move(dx, dy))
        lp.forceSpawnItem(p2, server.entities.trophy_guardian, team, true)
        clearFogInCircle(p2, team, 1.5)

        spawnStoneHand(assert(ppos:move(dx+1, dy)), team, 25, 3)
    end
end



local function spawnPulseButton(ent, dx,dy)
    dx = (dx or 0) - 4
    dy = (dy or 0) - 4
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(dx,dy)),
        server.entities.pulse_button_slot,
        team
    )
end


local NEXT_LEVEL_DX, NEXT_LEVEL_DY = -3, -4

local function spawnNextLevelButton(ent, dx,dy)
    dx = (dx or 0) + NEXT_LEVEL_DX
    dy = (dy or 0) + NEXT_LEVEL_DY
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(dx,dy)),
        server.entities.next_level_button_slot,
        team
    )
end




local function spawnDoomClock(ent, dx,dy)
    dx=dx or 0
    dy = dy or 0

    local plot = lp.getPos(ent):getPlot()
    local team = assert(ent.lootplotTeam)
    local ppos = assert(lp.getPos(ent)
        :move(dx, -4 + dy)
    )

    local dclock = server.entities.doom_clock()
    dclock._plotX, dclock._plotY = ppos:getCoords()
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local wppos = plot:getPPos(dclock._plotX, dclock._plotY)
    dclock.x, dclock.y, dclock.dimension = wppos:getWorldPos()

    -- Clear fog around doom clock
    clearFogInCircle(ppos, team, 1)
end


local function spawnDoomClockAndButtons(ent, dx,dy)
    spawnDoomClock(ent, dx,dy)

    -- next-level button
    spawnNextLevelButton(ent, dx,dy)

    -- pulse button
    local pulseButton = spawnPulseButton(ent, dx,dy)
    return pulseButton
end


local function spawnShop(ent, dx, dy)
    local ppos, team = getPosTeam(ent)
    ppos = assert(ppos:move(dx or 0,dy or 0))

    wg.spawnSlots(assert(ppos:move(-4,0)), server.entities.shop_slot, 3,1, team)
    wg.spawnSlots(assert(ppos:move(-3,2)), server.entities.food_shop_slot, 1,2, team)
end

local function spawnRerollButton(ent, dx,dy)
    local ppos, team = getPosTeam(ent)
    ppos = assert(ppos:move(dx or 0, dy or 0))
    wg.spawnSlots(assert(ppos:move(-4, -1)), server.entities.reroll_button_slot, 1,1, team)
end

local function spawnNormal(ent, dx,dy)
    dx = dx or 0
    dy = dy or 0
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(dx,dy)), server.entities.slot, 3,3, team)
end

local function spawnSell(ent, dx, dy)
    local ppos, team = getPosTeam(ent)
    ppos = assert(ppos:move(dx or 0, dy or 0))
    local slotEnt = lp.trySpawnSlot(assert(ppos:move(0, 3)), server.entities.sell_slot, team)
    return assert(slotEnt)
end

local function spawnMoneyLimit(ent)
    local ppos, team = getPosTeam(ent)
    local plot = ppos:getPlot()
    wg.spawnSlots(plot:getPPos(ppos:getCoords(), 2), server.entities.money_limit_slot, 1,1, team)
end

local function spawnInterestSlot(ent)
    local ppos, team = getPosTeam(ent)
    local plot = ppos:getPlot()
    wg.spawnSlots(plot:getPPos(ppos:getCoords(), 3), server.entities.interest_slot, 1,1, team)

end


local function spawnSkipSlots(ent)
    local ppos, team = getPosTeam(ent)
    local plot = ppos:getPlot()

    local x = ppos:getCoords()
    lp.forceSpawnSlot(plot:getPPos(x-1, 3), server.entities.golden_skip_slot, team)
    lp.forceSpawnSlot(plot:getPPos(x+1, 3), server.entities.golden_skip_slot, team)
end

-------------------------------------------------------------------

-------------------------------------------------------------------
---  Perk/starter-item definitions:
-------------------------------------------------------------------

-------------------------------------------------------------------

local MOVEMENT_TEXT = loc("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}WASD / Right click to move.\nScroll to zoom.{/outline}{/wavy}")

-- local OBJECTIVE_TEXT = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}{c r=1 g=0.4 b=0.3}You have {lootplot:INFO_COLOR}%{numRounds}{/lootplot:INFO_COLOR} Rounds to\nget the required points!{/outline}{/wavy}")


umg.defineEntityType("lootplot.s0:one_ball_tutorial_text", {
    lifetime = 50,
    drawDepth = 200,

    onUpdateServer = function(ent)
        local run = lp.singleplayer.getRun()
        if run and run:getAttribute("ROUND") > 1 then
            ent:delete()
        end
    end,

    onUpdateClient = function(ent)
        local run = lp.singleplayer.getRun()
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



local ONE_BALL_MONEY = 4

local UNLOCK_AFTER_TUTORIAL = function(_etype)
    return lp.metaprogression.getFlag("lootplot.s0:isTutorialCompleted")
end
defineStartingItem("one_ball", {
    name = loc("One Ball"),

    description = loc("Gain an extra $%{money} per turn", {
        money = ONE_BALL_MONEY
    }),

    baseMoneyGenerated = ONE_BALL_MONEY,
    baseMaxActivations = 2,

    winAchievement = "WIN_ONE_BALL",

    isEntityTypeUnlocked = UNLOCK_AFTER_TUTORIAL,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, -1) -- (make it easier for newbies)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)

        spawnDoomClock(ent)
        spawnPulseButton(ent)
        -- simple next-level-button slot CANNOT be skipped. This is to avoid noob-trap.
        if lp.getWinCount() < 1 then
            lp.forceSpawnSlot(assert(ppos:move(NEXT_LEVEL_DX, NEXT_LEVEL_DY)), server.entities.simple_next_level_button_slot, team)
        else
            lp.forceSpawnSlot(assert(ppos:move(NEXT_LEVEL_DX, NEXT_LEVEL_DY)), server.entities.next_level_button_slot, team)
        end

        -- Display tutorial text

        --[[
        -- dont display this for now... its a bit bloaty
        spawnTutorialText(assert(ppos:move(0, -3)), {
            text = OBJECTIVE_TEXT({
                numRounds = lp.getNumberOfRounds(ent)
            }),
            align = "center",
            oy = 10
        })
        ]]

        spawnTutorialText(assert(ppos:move(0, -1)), {
            text = MOVEMENT_TEXT,
            align = "center",
            oy = 10
        })

        clearFogInCircle(ppos, team, 4)
    end
})




-- unlocked after tutorial
defineStartingItem("six_ball", {
    name = loc("Six Ball"),

    triggers = {"PULSE", "REROLL"},

    description = loc("Reroll specialist"),

    baseMaxActivations = 3,
    baseMoneyGenerated = 2,

    isEntityTypeUnlocked = UNLOCK_AFTER_TUTORIAL,

    winAchievement = "WIN_SIX_BALL",

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)

        do -- spawn golden-die:
        local itemEnt2 = lp.trySpawnItem(assert(ppos:move(1,0)), server.entities.golden_die, team)
        itemEnt2.baseMoneyGenerated = 2
        end

        -- spawn green-olives:
        for y = -1,1 do
            local mpos = assert(ppos:move(3,y))
            lp.forceSpawnSlot(mpos, server.entities.null_slot, team)
            lp.forceSpawnItem(mpos, server.entities.green_olive, team)
        end

        ppos:getPlot():foreachSlot(function(slotEnt, _p)
            if not (lp.hasTrigger(slotEnt, "REROLL")) and (not slotEnt.buttonSlot) then
                lp.removeTrigger(slotEnt, "PULSE")
                lp.addTrigger(slotEnt, "REROLL")
            end
        end)

        spawnSell(ent)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end,
})




local FIVE_BALL_UNLOCK = 1
defineStartingItem("five_ball", {
    name = loc("Five Ball"),
    description = loc("Good with rotation"),

    activateDescription = loc("Rotates items"),

    unlockAfterWins = FIVE_BALL_UNLOCK,
    winAchievement = "WIN_FIVE_BALL",

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.rotateItem(targEnt, 1)
        end
    },

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        wg.spawnSlots(assert(ppos:move(0,-2)), server.entities.slot, 3,1, team)
        spawnSell(ent)

        lp.forceSpawnSlot(assert(ppos:move(0,-1)), server.entities.rotate_slot, team)

        lp.trySpawnItem(assert(ppos:move(1, 0)), server.entities.record_golden, team)

        -- spawn black-olives:
        for y = -1,1 do
            local mpos = assert(ppos:move(3,y))
            lp.forceSpawnSlot(mpos, server.entities.null_slot, team)
            lp.forceSpawnItem(mpos, server.entities.black_olive, team)
        end

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})




local G_BALL_UNLOCK = 2
defineStartingItem("G_ball", {
    name = loc("G Ball"),
    description = loc("Money is capped!"),

    baseMoneyGenerated = 1,
    grubMoneyCap = constants.DEFAULT_GRUB_MONEY_CAP,

    unlockAfterWins = G_BALL_UNLOCK,
    winAchievement = "WIN_G_BALL",

    onActivateOnce = function(ent)
        local ppos,team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)

        local slotEnt = lp.forceSpawnSlot(assert(ppos:move(0, -8)), server.entities.money_limit_slot, team)
        if slotEnt then
            slotEnt.grubMoneyCap = constants.DEFAULT_GRUB_MONEY_CAP
        end

        spawnNormal(ent)
        spawnShop(ent)

        do
        local pineapplePos = assert(ppos:move(-4,1))
        local slotEnt1 = lp.trySpawnSlot(pineapplePos, server.entities.slot, team)
        lp.trySpawnItem(pineapplePos, server.entities.pineapple_ring, team)
        if slotEnt1 then slotEnt1:delete() end
        -- i dont know WHY we gotta spawn a slot here, but for some reason it doesnt work withou it

        lp.trySpawnItem(assert(ppos:move(-3,-1)), server.entities["0_cent_ticket"], team)
        end

        do
        -- spawn money sack and sack-grubby
        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.null_slot, 1,3, team)

        lp.trySpawnItem(assert(ppos:move(3, 1)), server.entities.money_sack, team)
        lp.trySpawnItem(assert(ppos:move(3, -1)), server.entities.sack_grubby, team)
        end

        spawnRerollButton(ent)
        spawnSell(ent)
        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})



local S_BALL_UNLOCK = 2
defineStartingItem("S_ball", {
    name = loc("S Ball"),
    description = loc("Forced negative-bonus"),

    unlockAfterWins = S_BALL_UNLOCK,
    winAchievement = "WIN_S_BALL",

    onActivateOnce = function(ent)
        local ppos,team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)

        wg.spawnSlots(ppos, server.entities.sapphire_slot, 1,1, team)

        lp.forceSpawnSlot(assert(ppos:move(0,-2)), server.entities.null_slot, team)
        lp.forceSpawnItem(assert(ppos:move(0,-2)), server.entities.interdimensional_briefcase, team)

        spawnShop(ent)
        spawnRerollButton(ent)
        spawnSell(ent)
        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        lp.forceSpawnItem(assert(ppos:move(3, 0)), server.entities.aquarium_curse, team)

        clearFogInCircle(ppos, team, 4)
    end
})




local EIGHT_BALL_UNLOCK = 3
defineStartingItem("eight_ball", {
    name = loc("Eight Ball"),
    description = loc("Is surrounded by stone"),

    triggers = {"PULSE", "DESTROY"},
    baseMultGenerated = 1,
    lives = 99,

    unlockAfterWins = EIGHT_BALL_UNLOCK,
    winAchievement = "WIN_EIGHT_BALL",

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        local ppos, team = getPosTeam(ent)

        wg.spawnSlots(assert(ppos:move(0,2)), server.entities.slot, 3,7, team)

        wg.spawnSlots(assert(ppos:move(2,2)), server.entities.stone_slot, 1,9, team)
        wg.spawnSlots(assert(ppos:move(-2,2)), server.entities.stone_slot, 1,9, team)

        wg.spawnSlots(assert(ppos:move(0,6)), server.entities.stone_slot, 5,1, team)
        wg.spawnSlots(assert(ppos:move(0,-2)), server.entities.stone_slot, 5,1, team)

        lp.forceSpawnSlot(assert(ppos:move(0,2)), server.entities.sell_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(0,3)), server.entities.skull_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(0,4)), server.entities.sell_slot, team)

        do
        lp.trySpawnSlot(assert(ppos:move(4,-1)), server.entities.null_slot, team)
        lp.trySpawnItem(assert(ppos:move(4,-1)), server.entities.dark_bar, team)
        lp.trySpawnSlot(assert(ppos:move(4,0)), server.entities.null_slot, team)
        lp.trySpawnItem(assert(ppos:move(4,0)), server.entities.sack_dark, team)
        lp.trySpawnSlot(assert(ppos:move(4,1)), server.entities.null_slot, team)
        lp.trySpawnItem(assert(ppos:move(4,1)), server.entities.dark_bar, team)
        end

        spawnShop(ent, -1,0)
        spawnRerollButton(ent, -1,0)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end,
})







local SEVEN_BALL_UNLOCK = 3
defineStartingItem("seven_ball", {
    name = loc("Seven Ball"),
    description = loc("Dirt, Rocks, and a Bomb"),

    activateDescription = loc("30% chance to upgrade {lootplot:INFO_COLOR}Dirt Slots{/lootplot:INFO_COLOR}, allowing them to hold %{RARE} items", {
        RARE = lp.rarities.RARE.displayString
    }),

    unlockAfterWins = SEVEN_BALL_UNLOCK,
    winAchievement = "WIN_SEVEN_BALL",

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt:type() == "lootplot.s0:dirt_slot"
        end,
        activate = function(selfEnt, ppos, targEnt)
            if lp.SEED:randomMisc() <= 0.3 then
                lp.forceSpawnSlot(ppos, server.entities.gravel_slot, selfEnt.lootplotTeam)
            end
        end
    },

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        local ppos, team = getPosTeam(ent)

        local SPREAD = 3

        do -- spawn floaty bomb
        local p = assert(ppos:move(SPREAD + 2, 0))
        lp.forceSpawnSlot(p, server.entities.null_slot, team)
        local bombEnt = lp.forceSpawnItem(p, server.entities.bomb, team)
        bombEnt.canItemFloat = true
        end

        for x=-SPREAD, SPREAD do
            for y=-SPREAD, SPREAD do
                -- dont include corners, dont include center
                if (not (x==0 and y==0)) and (math.abs(x) + math.abs(y)) < (SPREAD * 2) then
                    local p = assert(ppos:move(x,y))
                    local r = lp.SEED:randomWorldGen()
                    if r < 0.3 then
                        local slotEnt = lp.forceSpawnSlot(p, server.entities.stone_slot, team)
                        slotEnt.baseMoneyGenerated = -15
                        slotEnt.canGoIntoDebt = true
                    elseif r < 0.9 then
                        lp.forceSpawnSlot(p, server.entities.dirt_slot, team)
                    else
                        -- do nothing; air
                    end
                end
            end
        end

        spawnShop(ent, -2,0)
        spawnRerollButton(ent, -2,0)
        spawnSell(ent, 0, 2)
        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})





local BLANK_BALL_UNLOCK = 3
defineStartingItem("blank_ball", {
    name = loc("Blank Ball"),
    description = loc("Has a Rulebender slot"),

    unlockAfterWins = BLANK_BALL_UNLOCK,
    winAchievement = "WIN_BLANK_BALL",

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)

        wg.spawnSlots(assert(ppos:move(-1,-2)), server.entities.shop_slot, 3,1, team)
        wg.spawnSlots(assert(ppos:move(2,-2)), server.entities.food_shop_slot, 2,1, team)
        wg.spawnSlots(assert(ppos:move(0,-3)), server.entities.reroll_button_slot, 1,1, team)

        wg.spawnSlots(assert(ppos:move(0,1)), server.entities.rulebender_slot, 1,1, team)

        spawnSell(ent)

        spawnDoomClockAndButtons(ent, -1)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end,
})






local AZAZEL_BALL_UNLOCK = 3
defineStartingItem("azazel_ball", {
    name = loc("Azazel Ball"),
    description = loc("Evil agreements..."),

    unlockAfterWins = AZAZEL_BALL_UNLOCK,
    -- winAchievement = "WIN_BOWLING_BALL",

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, 1)

        local shopDx=-1
        spawnRerollButton(ent, shopDx,0)
        spawnShop(ent, shopDx,0)
        spawnSell(ent, 0,2)

        lp.forceSpawnSlot(assert(ppos:move(0,-1)), server.entities.reversal_button_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(0,1)), server.entities.curse_button_slot, team)

        wg.spawnSlots(ppos, server.entities.gravel_slot, 3,5, team)
        wg.spawnSlots(ppos, server.entities.stone_slot, 5,7, team, function (ent)
            if lp.SEED:randomWorldGen() < 0.4 then
                lp.modifierBuff(ent, "multGenerated", 2)
            end
        end)


        local function randomItemType()
            if lp.SEED:randomWorldGen() < 0.1 then
                return lp.rarities.randomItemOfRarity(lp.rarities.LEGENDARY)
            elseif lp.SEED:randomWorldGen() < 0.5 then
                return lp.rarities.randomItemOfRarity(lp.rarities.RARE)
            else
                return lp.rarities.randomItemOfRarity(lp.rarities.EPIC)
            end
        end

        local function spawnOffer(p)
            local s = lp.trySpawnSlot(p, server.entities.offer_slot, team)
            if s then
                lp.trySpawnItem(p, randomItemType(), team)
            end
        end

        -- spawn offer-slots
        do
        local xx,yy = ppos:getCoords()
        local dx = 6
        xx = xx + dx

        local demonPos = assert(ppos:getPlot():getPPos(xx,yy))
        lp.forceSpawnSlot(demonPos, server.entities.gravel_slot, team)
        local shopDemon = lp.forceSpawnItem(demonPos, server.entities.shop_demon, team, true)
        if shopDemon then
            lp.targets.setShape(shopDemon, lp.targets.KingShape(2))
            shopDemon.baseMoneyGenerated = -20
        end

        ppos:getPlot():foreachInArea(xx-2,yy-2, xx+2,yy+2, function (pos)
            local x,y = pos:getCoords()
            local ddx, ddy = xx-x, yy-y
            if math.abs(ddx) >= 2 or math.abs(ddy) >= 2 then
                spawnOffer(pos)
            end
        end)
        end

        spawnDoomClockAndButtons(ent, 0,0)
        spawnCurses(ent, 0,0)

        clearFogInCircle(ppos, team, 4)
    end
})







local AETHER_BALL_UNLOCK = 4
defineStartingItem("aether_ball", {
    name = loc("Aether Ball"),
    description = loc("No slots, only sky!"),

    unlockAfterWins = AETHER_BALL_UNLOCK,
    -- winAchievement = "WIN_BOWLING_BALL",

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, 1)

        spawnRerollButton(ent)
        spawnShop(ent)
        spawnSell(ent)

        lp.forceSpawnItem(assert(ppos:move(4,0)), server.entities.blank_eraser, team, true)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        do
        local SHAPE = lp.targets.KingShape(9)

        local b = assert(lp.trySpawnItem(assert(ppos:move(-4,1)), server.entities.white_balloon, team, true))
        lp.targets.setShape(b, SHAPE)

        b = assert(lp.trySpawnItem(assert(ppos:move(-5,1)), server.entities.white_balloon, team, true))
        lp.targets.setShape(b, SHAPE)

        b = assert(lp.trySpawnItem(assert(ppos:move(-4,2)), server.entities.white_balloon, team, true))
        lp.targets.setShape(b, SHAPE)
        end

        local TREASURE_CHANCE = 0.01
        local STONE_CHANCE = 0.65
        local STONE_SLOT_INVINCIBILITY_CHANCE = 0.55

        local plot = ppos:getPlot()
        plot:foreach(function(pos)
            local r = lp.SEED:randomWorldGen()
            if not lp.posToItem(pos) then
                if r < TREASURE_CHANCE then
                    local slotEnt = lp.trySpawnSlot(pos, server.entities.null_slot, team)
                    if slotEnt then
                        lp.forceSpawnItem(pos, server.entities.chest_legendary, team)
                    end
                elseif r < STONE_CHANCE then
                    -- (dont set it as player-team; coz then it removes fog)
                    local slotEnt = lp.trySpawnSlot(pos, server.entities.stone_slot, "@")
                    if slotEnt and (lp.SEED:randomWorldGen() < STONE_SLOT_INVINCIBILITY_CHANCE) then
                        slotEnt.isInvincible = true
                    end
                end
            end
        end)

        clearFogInCircle(ppos, team, 4)
    end
})










local NINE_BALL_UNLOCK = 4

defineStartingItem("nine_ball", {
    name = loc("Nine Ball"),
    description = loc("Tax burden is heavy"),

    unlockAfterWins = NINE_BALL_UNLOCK,
    winAchievement = "WIN_NINE_BALL",

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        wg.spawnSlots(assert(ppos:move(4,0)), server.entities.null_slot, 3,3, team, function(slotEnt)
            slotEnt.canGoIntoDebt = true
            slotEnt.baseMoneyGenerated = -2
        end)

        lp.forceSpawnSlot(
            assert(ppos:move(4, 0)),
            server.entities.tax_button_slot,
            team
        )

        clearFogInCircle(ppos, team, 4)
    end
})






local L_BALL_UNLOCK = 5
defineStartingItem("L_ball", {
    name = loc("L Ball"),
    description = loc("No basic slots!"),

    unlockAfterWins = L_BALL_UNLOCK,
    winAchievement = "WIN_L_BALL",

    activateDescription = loc("Gives {lootplot:LIFE_COLOR}+1 lives{/lootplot:LIFE_COLOR} to slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)

        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)

        lp.forceSpawnSlot(ppos, server.entities.pink_slot, team)

        lp.forceSpawnItem(assert(ppos:move(3, 0)), server.entities.eraser_curse, team)

        wg.spawnSlots(assert(ppos:move(0,-3)), server.entities.null_slot, 1,1, team)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end,

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            targEnt.lives = (targEnt.lives or 0) + 1
        end,
        activateWithNoValidTargets = true
    }
})





local RAINBOW_BALL_UNLOCK = 5
defineStartingItem("rainbow_ball", {
    name = loc("Rainbow Ball"),
    description = loc("Roy G Biv!"),

    unlockAfterWins = RAINBOW_BALL_UNLOCK,
    winAchievement = "WIN_RAINBOW",

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, -4)
        local ppos, team = getPosTeam(ent)

        local curPos = assert(ppos:move(-4, 1))

        local function nextPos()
            curPos = assert(curPos:move(1,0))
            return curPos
        end

        local ents = server.entities
        lp.forceSpawnSlot(nextPos(), ents.next_level_button_slot, team) -- red
        lp.forceSpawnSlot(nextPos(), ents.food_shop_slot, team) -- orange
        lp.forceSpawnSlot(nextPos(), ents.shop_slot, team) -- yellow
        lp.forceSpawnSlot(nextPos(), ents.reroll_button_slot, team) -- green
        lp.forceSpawnSlot(nextPos(), ents.pulse_button_slot, team) -- blue
        lp.forceSpawnSlot(nextPos(), ents.sapphire_slot, team) -- indigo
        lp.forceSpawnSlot(nextPos(), ents.rulebender_slot, team) -- violet

        spawnDoomClock(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})




local EDEN_BALL_UNLOCK = 5
defineStartingItem("eden_ball", {
    name = loc("Eden Ball"),
    description = loc("Less rounds per level"),

    unlockAfterWins = EDEN_BALL_UNLOCK,
    -- winAchievement = "WIN_RAINBOW",

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, math.ceil(constants.ROUNDS_PER_LEVEL / 2) + 1)
        lp.setAttribute("ROUND", ent, 0)
        local ppos, team = getPosTeam(ent)

        lp.forceSpawnSlot(ppos, server.entities.guardian_slot, team)

        spawnRerollButton(ent)
        spawnShop(ent)

        spawnNextLevelButton(ent)
        spawnPulseButton(ent)

        local squares = {
            ppos:move(-8, -6),
            ppos:move(-4, -3),
            ppos:move(0, 2),
            ppos:move(4, -6),
            ppos:move(8, -2),
            ppos:move(-6, 2),
            ppos:move(0, -4),
            ppos:move(-2, 6),
            ppos:move(6, 6),
            ppos:move(-9, 1)
        }
        local function randomItemType()
            if lp.SEED:randomWorldGen() < 0.2 then
                return lp.rarities.randomItemOfRarity(lp.rarities.UNCOMMON)
            elseif lp.SEED:randomWorldGen() < 0.8 then
                return lp.rarities.randomItemOfRarity(lp.rarities.RARE)
            else
                return lp.rarities.randomItemOfRarity(lp.rarities.EPIC)
            end
        end

        local function spawnCloud(p,dx,dy)
            p = assert(p:move(dx,dy))
            lp.trySpawnSlot(p, server.entities.cloud_slot, team)
            lp.trySpawnItem(p, randomItemType(), team)
        end

        for _,p in ipairs(squares) do
            spawnCloud(p,0,0)
            spawnCloud(p,0,1)
            spawnCloud(p,1,0)
            spawnCloud(p,1,1)
        end

        spawnDoomClock(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})




local NEGATIVE_ONE_BALL_UNLOCK = 6
local NEGATIVE_ONE_BALL_START_MONEY = 750

defineStartingItem("negative_one_ball", {
    name = loc("Negative One Ball"),
    description = loc("Start with $%{moneh}.\nMoney never goes up.", {
        moneh = NEGATIVE_ONE_BALL_START_MONEY
    }),

    unlockAfterWins = NEGATIVE_ONE_BALL_UNLOCK,
    -- winAchievement = "WIN_RAINBOW",

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, 1)
        lp.setAttribute("MONEY", ent, NEGATIVE_ONE_BALL_START_MONEY)

        local ppos, team = getPosTeam(ent)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        lp.forceSpawnItem(assert(ppos:move(-4,1)), server.entities.grubby_balloon, team, true)

        lp.forceSpawnItem(assert(ppos:move(4,0)), server.entities.golden_lock_curse, team, true)

        spawnDoomClock(ent)
        spawnPulseButton(ent)
        spawnNextLevelButton(ent)

        clearFogInCircle(ppos, team, 4)
    end
})








local BOWLING_BALL_UNLOCK = 6
defineStartingItem("bowling_ball", {
    name = loc("Bowling Ball"),
    description = loc("STRIKE!"),

    activateDescription = loc("Increases {lootplot:DOOMED_LIGHT_COLOR}doom-count{/lootplot:DOOMED_LIGHT_COLOR} of slots by 2"),

    unlockAfterWins = BOWLING_BALL_UNLOCK,
    winAchievement = "WIN_BOWLING_BALL",

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targEnt)
            targEnt.doomCount = targEnt.doomCount + 2
        end
    },

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, -4)

        spawnRerollButton(ent)
        spawnShop(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)

        do
        local nullSlot = lp.forceSpawnSlot(assert(ppos:move(0, -2)), server.entities.null_slot, team)
        nullSlot.doomCount = 50
        lp.modifierBuff(nullSlot, "moneyGenerated", -1)
        end

        ent.baseMoneyGenerated = -2

        wg.spawnSlots(ppos, server.entities.slot, 1,1, team)

        local plot = ppos:getPlot()
        plot:foreachSlot(function(slotEnt, _ppos)
            if not slotEnt.doomCount then
                slotEnt.doomCount = lp.SEED:randomMisc(7, 15)
            end
        end)

        spawnDoomClockAndButtons(ent)
        spawnCurses(ent)

        clearFogInCircle(ppos, team, 4)
    end
})









local DAILY_RUN_UNLOCK = 3

defineStartingItem("basketball", {
    name = loc("Basketball"),
    description = loc("Randomized daily!"),

    unlockAfterWins = DAILY_RUN_UNLOCK,

    onActivateOnce = function(ent)
        local ppos,team = getPosTeam(ent)
        local _, dInfo = lp.getDifficulty()

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)

        spawnDoomClock(ent)

        daily.generate({
            plot = ppos:getPlot(),
            team = team,
            difficulty = dInfo.difficulty
        })

        clearFogInCircle(ppos, team, 4)
    end
})







-- ==================
----------
-- ITEM COMPENDIUM!
----------
-- ==================

do

local LOCKED_WINS_DESC = interp("Unlocked after winning %{X} times")
local LOCKED_UNKNOWN_DESC = loc("Unlocked after ???")

lp.defineItem("lootplot.s0:compendium_locked_item", {
    name = loc("Locked item!"),
    image = "compendium_locked_item_big",
    description = function(ent)
        if umg.exists(ent) then
            if not ent.itemTypeId then return "" end
            local etype = ent.itemTypeId and client.entities[ent.itemTypeId]
            local winCount = etype.unlockAfterWins
            if winCount then
                return LOCKED_WINS_DESC({
                    X = winCount
                })
            else
                return LOCKED_UNKNOWN_DESC
            end
        end
        return " "
    end
})


local COMPENDIUM_DESC = loc("Buy this item in a run to view it!")

lp.defineItem("lootplot.s0:compendium_unseen_item", {
    name = loc("Unseen item!"),
    image = "compendium_locked_item_big",
    description = COMPENDIUM_DESC,

    color = {0,0,0},

    onUpdateClient = function (ent)
        local etype = ent.itemTypeId and client.entities[ent.itemTypeId]
        if etype and etype.image then
            ent.image = etype.image
        end
    end
})



local compendium = server and require("server.compendium")


lp.defineSlot("lootplot.s0:compendium_slot", {
    name = loc("Compendium Slot"),
    triggers = {"PULSE"},

    basePrice = 0,

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,
    audioVolume = 0,

    onActivate = function(ent)
        if not ent.itemTypeId then return end
        local etype = ent.itemTypeId and server.entities[ent.itemTypeId]
        local ppos, team = assert(lp.getPos(ent)), ent.lootplotTeam
        if not etype then return end
        if lp.metaprogression.isEntityTypeUnlocked(etype) then
            if compendium.isSeen(ent.itemTypeId) then
                lp.forceSpawnItem(ppos, etype, team)
            else
                local item = lp.forceSpawnItem(ppos, server.entities.compendium_unseen_item, team)
                item.itemTypeId = ent.itemTypeId
            end
        else
            local item = lp.forceSpawnItem(ppos, server.entities.compendium_locked_item, team)
            item.itemTypeId = ent.itemTypeId
        end
    end
})


defineStartingItemNoDifficulty("compendium_cat", {
    name = loc("Compendium Cat"),
    description = loc("It's Sandbox time!"),

    unlockAfterWins = 1,

    onActivateOnce = function(ent)
        local ppos,team = assert(lp.getPos(ent)), ent.lootplotTeam
        local plot = ppos:getPlot()

        compendium.setEnabled(false)

        local rr = lp.rarities
        local ALLOWED_RARITIES = {
            [rr.COMMON] = true,
            [rr.UNCOMMON] = true,
            [rr.RARE] = true,
            [rr.EPIC] = true,
            [rr.LEGENDARY] = true,
        }

        lp.setMoney(ent, 10000)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, 1000)
        lp.setAttribute("REQUIRED_POINTS", ent, 0)

        local allItems = lp.newItemGenerator():getEntries()
        local sorted = objects.Array(allItems)
            :map(function (itemTypeId)
                local etype = server.entities[itemTypeId]
                if etype and ALLOWED_RARITIES[etype.rarity] then
                    return etype
                end
            end)
        sorted:sortInPlace(function(etypeA, etypeB)
            local rA = etypeA.rarity
            local rB = etypeB.rarity
            local lockedA = (lp.metaprogression.isEntityTypeUnlocked(etypeA) and 1) or 0
            local lockedB = (lp.metaprogression.isEntityTypeUnlocked(etypeB) and 1) or 0
            return
                rA.rarityWeight + lockedA*10000
                <
                rB.rarityWeight + lockedB*10000
        end)

        local cpos = plot:getCenterPPos()
        local cx,cy = cpos:getCoords()
        local VIEW_AREA_WIDTH = 15
        local VIEW_AREA_START_X = cx - math.floor(VIEW_AREA_WIDTH/2)
        local x, y = 1, 7
        for _, itemEType in ipairs(sorted) do
            if x >= VIEW_AREA_WIDTH then
                y = y + 1
                x = 1
            end

            local pos = plot:getPPos(x + VIEW_AREA_START_X, y)
            local slot = lp.forceSpawnSlot(pos, server.entities.compendium_slot, team)
            slot.itemTypeId = itemEType:getTypename()
            lp.forceActivateEntity(slot)

            x = x + 1
        end

        do
        local px = VIEW_AREA_START_X + VIEW_AREA_WIDTH + 2
        local py = cy

        local posp = plot:getPPos(px,py)
        local mpos = posp:move(4,-2)
        local mpos2 = posp:move(4,2)
        if mpos and mpos2 then
            wg.spawnSlots(mpos, server.entities.slot, 3,3, team)

            wg.spawnSlots(mpos2, server.entities.null_slot, 3,3, team, function (e)
                lp.modifierBuff(e, "moneyGenerated", 10)
            end)
        end

        lp.forceSpawnSlot(assert(posp:move(1,0)), server.entities.pulse_button_slot, team)
        lp.forceSpawnSlot(assert(posp:move(-1,0)), server.entities.compendium_button_slot, team)

        lp.forceSpawnSlot(assert(posp:move(0, 4)), server.entities.key_cloth_slot, team)
        lp.forceSpawnSlot(assert(posp:move(0, 2)), server.entities.reroll_button_slot, team)
        lp.forceSpawnSlot(assert(posp:move(0, -2)), server.entities.rotate_slot, team)
        lp.forceSpawnSlot(assert(posp:move(0, -4)), server.entities.level_cloth_slot, team)
        end
    end
})

end

