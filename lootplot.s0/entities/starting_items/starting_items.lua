
local loc = localization.localize
local interp = localization.newInterpolator
local wg = lp.worldgen

local constants = require("shared.constants")


--[[
we need to make sure tutorial-cat is loaded first,
because that starting-item should be shown FIRST.
]]
require("entities.tutorial.tutorial")
-- (Since the order of `lp.worldgen.STARTING_ITEMS` matters!)



local defPerkTc = typecheck.assert("string", "table")

local function definePerk(id, etype)
    defPerkTc(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float
    etype.triggers = etype.triggers or {"PULSE"}
    assert(lp.hasTrigger(etype, "PULSE"), "?")

    id = "lootplot.s0:" .. id
    lp.defineItem(id, etype)
    lp.worldgen.STARTING_ITEMS:add(id)
end



local function makeAchievementUnlocker(achievementName)
    return function()
        umg.achievements.unlockAchievement(achievementName)
    end
end



local function unlockAfterWins(numberOfWins)
    local isEntityTypeUnlocked = function(etype)
        if lp.getWinCount() >= numberOfWins then
            return true
        end
    end

    return isEntityTypeUnlocked
end


-- Starting-items are unlocked in order of definition,
-- Each time you win a game, you unlock a new starting-item.
local UNLOCK_WIN_COUNT = 2
local function winToUnlock()
    local currWinCount = UNLOCK_WIN_COUNT -- capture closure
    UNLOCK_WIN_COUNT = UNLOCK_WIN_COUNT + 1
    local function isUnlocked()
        if lp.getWinCount() >= currWinCount then
            return true
        end
        return false
    end
    return isUnlocked
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



local NEXT_LEVEL_DX, NEXT_LEVEL_DY = -3, -4

local function spawnNextLevelButton(ent)
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(NEXT_LEVEL_DX, NEXT_LEVEL_DY)),
        server.entities.next_level_button_slot,
        team
    )
end

local function spawnPulseButton(ent)
    local ppos, team = getPosTeam(ent)
    return lp.forceSpawnSlot(
        assert(ppos:move(-4,-4)),
        server.entities.pulse_button_slot,
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

    -- Meta-buttons
    local pulseButton = spawnPulseButton(ent)
    local nextLevelButton = spawnNextLevelButton(ent)
    return pulseButton, nextLevelButton
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

definePerk("one_ball", {
    name = loc("One Ball"),

    description = loc("Gain an extra $%{money} per turn", {
        money = ONE_BALL_MONEY
    }),

    baseMoneyGenerated = ONE_BALL_MONEY,
    baseMaxActivations = 2,

    onWinGame = makeAchievementUnlocker("WIN_ONE_BALL"),

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
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        spawnDoomClockAndButtons(ent)

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



definePerk("five_ball", {
    name = loc("Five Ball"),
    description = loc("Good with rotation"),

    isEntityTypeUnlocked = unlockAfterWins(1),
    onWinGame = makeAchievementUnlocker("WIN_FIVE_BALL"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        lp.trySpawnItem(assert(ppos:move(1, 0)), server.entities.record_golden, team)
        lp.trySpawnItem(assert(ppos:move(-1, 0)), server.entities.record_white, team)

        spawnDoomClockAndButtons(ent)

        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.rotate_slot, 1,1, team)
    end
})





definePerk("six_ball", {
    name = loc("Six Ball"),

    triggers = {"PULSE", "REROLL"},

    description = loc("Reroll specialist"),
    activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items."),

    baseMaxActivations = 10,

    isEntityTypeUnlocked = unlockAfterWins(1),
    onWinGame = makeAchievementUnlocker("WIN_SIX_BALL"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)

        do -- spawn golden-die:
        local itemEnt = lp.trySpawnItem(assert(ppos:move(-1,0)), server.entities.golden_die, team)
        itemEnt.baseMoneyGenerated = 3
        local itemEnt2 = lp.trySpawnItem(assert(ppos:move(1,0)), server.entities.golden_die, team)
        itemEnt2.baseMoneyGenerated = 3
        end

        do -- spawn green-olive with lives:
        local p = assert(ppos:move(3,0))
        lp.trySpawnSlot(p, server.entities.null_slot, team)
        local itemEnt = lp.trySpawnItem(p, server.entities.green_olive, team)
        if itemEnt then
            itemEnt.lives = 10
        end
        end

        ppos:getPlot():foreachSlot(function(slotEnt, _p)
            if not (lp.hasTrigger(slotEnt, "REROLL")) and (not slotEnt.buttonSlot) then
                lp.addTrigger(slotEnt, "REROLL")
            end
        end)

        spawnPulseButton(ent)
        spawnNextLevelButton(ent)
        spawnDoomClock(ent)
    end,

    shape = lp.targets.UpShape(4),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "PULSE")
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})



definePerk("four_ball", {
    name = loc("Four Ball"),
    description = loc("Has 2 extra rounds per level"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_FOUR_BALL"),

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        local numRounds = constants.ROUNDS_PER_LEVEL + 2
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, numRounds)
        spawnNormal(ent)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        spawnDoomClockAndButtons(ent)
    end
})




definePerk("L_ball", {
    name = loc("L Ball"),
    description = loc("Gives lives to items/slots"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_L_BALL"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        wg.spawnSlots(assert(ppos:move(0,-3)), server.entities.null_slot, 1,1, team)

        ent.baseMoneyGenerated = -5
        -- reason we must do set it here instead of as a shcomp,
        -- is because money starts at 0. If it's a shcomp, onActivateOnce will never be called!

        spawnDoomClockAndButtons(ent)
    end,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targEnt)
            targEnt.lives = (targEnt.lives or 0) + 1
        end
    }
})




definePerk("seven_ball", {
    name = loc("Seven Ball"),
    description = loc("Dirt, Rocks, and a Bomb"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_SEVEN_BALL"),

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
                        slotEnt.baseMoneyGenerated = -3
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
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        spawnDoomClockAndButtons(ent)
    end
})





definePerk("eight_ball", {
    name = loc("Eight Ball"),
    description = loc("Is surrounded by stone"),

    activateDescription = loc("Destroys items"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_EIGHT_BALL"),

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        local ppos, team = getPosTeam(ent)

        wg.spawnSlots(ppos, server.entities.slot, 3,1, team)
        wg.spawnSlots(ppos, server.entities.slot, 1,3, team)

        wg.spawnSlots(assert(ppos:move(2,0)), server.entities.stone_slot, 1,3, team)
        wg.spawnSlots(assert(ppos:move(-2,0)), server.entities.stone_slot, 1,3, team)

        wg.spawnSlots(assert(ppos:move(0,2)), server.entities.stone_slot, 3,1, team)
        wg.spawnSlots(assert(ppos:move(0,-2)), server.entities.stone_slot, 3,1, team)

        lp.forceSpawnSlot(assert(ppos:move(1,1)), server.entities.stone_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(1,-1)), server.entities.stone_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(-1,1)), server.entities.stone_slot, team)
        lp.forceSpawnSlot(assert(ppos:move(-1,-1)), server.entities.stone_slot, team)

        spawnShop(ent, -1,0)
        spawnRerollButton(ent, -1,0)

        wg.spawnSlots(assert(ppos:move(0,4)), server.entities.skull_slot, 3,1, team)

        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)
        spawnDoomClockAndButtons(ent)
    end,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.destroy(targEnt)
        end
    }
})






definePerk("blank_ball", {
    name = loc("Blank Ball"),
    description = loc("Has a Rulebender slot"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_BLANK_BALL"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)

        wg.spawnSlots(assert(ppos:move(-1,-2)), server.entities.shop_slot, 3,1, team)
        wg.spawnSlots(assert(ppos:move(2,-2)), server.entities.food_shop_slot, 2,1, team)
        wg.spawnSlots(assert(ppos:move(0,-3)), server.entities.reroll_button_slot, 1,1, team)

        wg.spawnSlots(assert(ppos:move(2, 0)), server.entities.slot, 1,3, team)
        wg.spawnSlots(assert(ppos:move(-2, 0)), server.entities.slot, 1,3, team)

        wg.spawnSlots(assert(ppos:move(0,1)), server.entities.rulebender_slot, 1,1, team)

        spawnSell(ent)
        spawnInterestSlot(ent)
        spawnMoneyLimit(ent)

        spawnDoomClockAndButtons(ent, -1)
    end,
})




do
local COST_TO_LEVEL_UP = 60

definePerk("nine_ball", {
    name = loc("Nine Ball"),
    description = loc("Costs $$$ to level-up"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_NINE_BALL"),

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, COST_TO_LEVEL_UP)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        spawnShop(ent)
        spawnRerollButton(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnInterestSlot(ent)

        local slotEnt = lp.posToSlot(ppos)
        slotEnt.baseMoneyGenerated = -1

        spawnDoomClock(ent)
        spawnPulseButton(ent)

        local nextLevelButton = lp.forceSpawnSlot(
            assert(ppos:move(NEXT_LEVEL_DX, NEXT_LEVEL_DY)),
            server.entities.golden_next_level_button_slot,
            team
        )
        nextLevelButton.baseMoneyGenerated = -COST_TO_LEVEL_UP
    end
})

end



definePerk("rainbow_ball", {
    name = loc("Gay"),
    description = loc("gay."),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_GAY"),

    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, -1)
        local ppos, team = getPosTeam(ent)

        local curPos = assert(ppos:move(-4, 1))

        local function nextPos()
            curPos = assert(curPos:move(1,0))
            return curPos
        end

        local ents = server.entities
        lp.forceSpawnSlot(nextPos(), ents.next_level_button_slot, team) -- red
        lp.forceSpawnSlot(nextPos(), ents.rotate_slot, team) -- orange
        lp.forceSpawnSlot(nextPos(), ents.shop_slot, team) -- yellow
        lp.forceSpawnSlot(nextPos(), ents.reroll_button_slot, team) -- green
        lp.forceSpawnSlot(nextPos(), ents.pulse_button_slot, team) -- blue
        lp.forceSpawnSlot(nextPos(), ents.sapphire_slot, team) -- indigo
        lp.forceSpawnSlot(nextPos(), ents.food_shop_slot, team) -- violet

        spawnDoomClock(ent)
    end
})





definePerk("bowling_ball", {
    name = loc("Bowling Ball"),
    description = loc("CHALLENGE-ITEM!"),

    isEntityTypeUnlocked = winToUnlock(),
    onWinGame = makeAchievementUnlocker("WIN_BOWLING_BALL"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        lp.setMoney(ent, constants.STARTING_MONEY)
        lp.setAttribute("NUMBER_OF_ROUNDS", ent, constants.ROUNDS_PER_LEVEL)
        lp.setAttribute("ROUND", ent, -1)

        spawnShop(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)

        ent.baseMoneyGenerated = -1

        wg.spawnSlots(ppos, server.entities.slot, 1,3, team)
        for y=-1, 1, 2 do
            local slotEnt = lp.posToSlot(assert(ppos:move(0, y)))
            slotEnt.baseMoneyGenerated = -1
        end

        local plot = ppos:getPlot()
        plot:foreachSlot(function(slotEnt, _ppos)
            slotEnt.doomCount = lp.SEED:randomMisc(15, 25)
        end)

        spawnDoomClockAndButtons(ent)
    end
})


