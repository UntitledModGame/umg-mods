
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


local function spawnCurses(ent)
    local ppos, team = getPosTeam(ent)
    local d, dInfo = lp.getDifficulty()
    if dInfo.difficulty == 1 then
        -- normal mode
        spawnStoneHand(assert(ppos:move(0, -10)), team, 25, 3)
    elseif dInfo.difficulty >= 2 then
        -- HARD mode
        spawnStoneHand(assert(ppos:move(-4, -10)), team, 15, 2)

        local p2 = assert(ppos:move(0, -12))
        lp.forceSpawnItem(p2, server.entities.trophy_guardian, team, true)
        clearFogInCircle(p2, team, 1.5)

        spawnStoneHand(assert(ppos:move(4, -10)), team, 25, 3)
    end
end



local function spawnPulseButton(ent)
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(-4,-4)),
        server.entities.pulse_button_slot,
        team
    )
end


local NEXT_LEVEL_DX, NEXT_LEVEL_DY = -3, -4

local function spawnNextLevelButton(ent)
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(NEXT_LEVEL_DX, NEXT_LEVEL_DY)),
        server.entities.next_level_button_slot,
        team
    )
end




local function spawnDoomClock(ent, dy)
    dy = dy or 0

    local plot = lp.getPos(ent):getPlot()
    local team = assert(ent.lootplotTeam)
    local ppos = assert(lp.getPos(ent)
        :move(0, -4 + dy)
    )

    local dclock = server.entities.doom_clock()
    dclock._plotX, dclock._plotY = ppos:getCoords()
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local wppos = plot:getPPos(dclock._plotX, dclock._plotY)
    dclock.x, dclock.y, dclock.dimension = wppos:getWorldPos()

    -- Clear fog around doom clock
    clearFogInCircle(ppos, team, 1)
end


local function spawnDoomClockAndButtons(ent, dy)
    spawnDoomClock(ent, dy)

    -- next-level button
    spawnNextLevelButton(ent)

    -- pulse button
    local pulseButton = spawnPulseButton(ent)
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

local function spawnNormal(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(ppos, server.entities.slot, 3,3, team)
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

defineStartingItem("one_ball", {
    name = loc("One Ball"),

    description = loc("Gain an extra $%{money} per turn", {
        money = ONE_BALL_MONEY
    }),

    baseMoneyGenerated = ONE_BALL_MONEY,
    baseMaxActivations = 2,

    winAchievement = "WIN_ONE_BALL",

    isEntityTypeUnlocked = function(_etype)
        return lp.metaprogression.getFlag("lootplot.s0:isTutorialCompleted")
    end,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
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
    end
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
    end
})





local SIX_BALL_UNLOCK = 1
defineStartingItem("six_ball", {
    name = loc("Six Ball"),

    triggers = {"PULSE", "REROLL"},

    description = loc("Reroll specialist"),

    baseMaxActivations = 10,
    baseMoneyGenerated = 2,

    unlockAfterWins = SIX_BALL_UNLOCK,
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
    end,
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
    end,
})






local L_BALL_UNLOCK = 3
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




local SEVEN_BALL_UNLOCK = 4
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
        activate = function(ent)
            local ppos = lp.getPos(ent)
            if lp.SEED:randomMisc() <= 0.3 then
                lp.forceSpawnSlot(assert(ppos), server.entities.gravel_slot, ent.lootplotTeam)
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
    end
})






local BLANK_BALL_UNLOCK = 4
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
    end,
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
    end
})




local RAINBOW_BALL_UNLOCK = 4
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
    end
})





local BOWLING_BALL_UNLOCK = 4
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

        daily.generate({
            plot = ppos:getPlot(),
            team = team,
            difficulty = dInfo.difficulty
        })

        spawnDoomClock(ent)
    end
})


