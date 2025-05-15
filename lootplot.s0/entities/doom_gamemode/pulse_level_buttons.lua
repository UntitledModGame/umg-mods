

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]

local constants = require("shared.constants")
local helper = require("shared.helper")


local loc = localization.localize
local interp = localization.newInterpolator

local function fogFilter(ppos, ent)
    local plot = ppos:getPlot()
    local team = ent.lootplotTeam
    if team then
        return plot:isFogRevealed(ppos, team) and lp.hasTrigger(ent, "PULSE")
    else
        return false
    end
end

---@param ppos lootplot.PPos
local function resetPlot(ppos)
    local plot = ppos:getPlot()
    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:foreachLayerEntry(function(e, _ppos, layer)
            lp.resetEntity(e)
        end)
    end)
end


local function hasLost(e)
    local numberOfRounds = lp.getNumberOfRounds(e)
    local round = lp.getRound(e)
    local requiredPoints = lp.getRequiredPoints(e)
    local points = lp.getPoints(e)

    if (round > numberOfRounds) and (points < requiredPoints) then
        return true
    end
end


---@param plot lootplot.Plot
local function deleteAllButtonSlots(plot)
    plot:foreachSlot(function(ent, ppos)
        if ent.buttonSlot then
            ent:delete()
        end
    end)
end



---@param plot lootplot.Plot
---@return string[]
local function getAllItems(plot)
    -- a string list of items on the plot:
    -- {"lootplot.s0:dragonfruit", "lootplot.s0:blueberry", "iron_sword"}
    local allItems = {}
    local itemSet = {}
    plot:foreachItem(function(itemEnt, _ppos)
        local itemId = itemEnt:getEntityType():getTypename()
        if not itemSet[itemId] then
            table.insert(allItems, itemId)
        end
        itemSet[itemId] = true
    end)
    return allItems
end



local function loseGame(ent, plot)
    lp.loseGame(plot, ent.lootplotTeam)

    -- destroy all button-slots:
    deleteAllButtonSlots(plot)
end



---@param plot lootplot.Plot
local function winGame(plot)
    -- oh damn!! GG! :)
    lp.winGame(plot, server.getHostClient())
    deleteAllButtonSlots(plot)
end




local function buttonOnDraw(ent)
    -- NOTE: this is a bit weird/hacky, 
    -- since we aren't actually drawing anything..
    -- but its "fine"
    if not lp.canActivateEntity(ent) then
        ent.opacity = 0.3
    else
        ent.opacity = 1
    end
end



do
local AFTER_ACTIVATION = interp("(Afterwards earns {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR})")


lp.defineSlot("lootplot.s0:pulse_button_slot", {
    image = "pulse_button_up",

    name = loc("Pulse Button"),
    description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots,\nand go to the next round!"),
    activateDescription = function(ent)
        return AFTER_ACTIVATION({
            money = helper.getMoneyPerRound()
        })
    end,

    activateAnimation = {
        activate = "pulse_button_hold",
        idle = "pulse_button_up",
        duration = 0.1
    },

    onDraw = buttonOnDraw,

    baseMaxActivations = 3,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.RARE,

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local numOfRounds = lp.getNumberOfRounds(ent)
        if round <= numOfRounds then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            local plot = ppos:getPlot()
            resetPlot(ppos)

            -- LIFO: we want to do this stuff last, so we queue this FIRST.
            lp.queueWithEntity(ent, function(e)
                lp.addMoney(e, helper.getMoneyPerRound())
                lp.setPointsMult(e, 1)
                lp.setPointsBonus(e, 0)

                local round = lp.getAttribute("ROUND", e)
                local newRound = round + 1
                lp.setRound(e, newRound)

                if hasLost(e) then
                    loseGame(e, plot)
                end
            end)

            lp.Bufferer()
                :all(plot)
                :to("SLOT_OR_ITEM") -- ppos-->slot
                :filter(fogFilter)
                :execute(function(ppos1, slotEnt)
                    lp.resetCombo(slotEnt)
                    lp.tryTriggerSlotThenItem("PULSE", ppos1)
                end)

            resetPlot(ppos)
        end
    end,
})

end




lp.defineSlot("lootplot.s0:gray_pulse_button_slot", {
    image = "gray_pulse_button_up",

    name = loc("Gray Button"),
    description = loc("Click to go to the next round."),
    activateDescription = loc("(Afterwards earns {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR})", {
        money = constants.MONEY_PER_ROUND
    }),

    activateAnimation = {
        activate = "gray_pulse_button_hold",
        idle = "gray_pulse_button_up",
        duration = 0.1
    },

    onDraw = buttonOnDraw,

    baseMaxActivations = 3,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.UNIQUE,

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local numOfRounds = lp.getNumberOfRounds(ent)
        if round <= numOfRounds then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            local plot = ppos:getPlot()
            resetPlot(ppos)

            -- LIFO: we want to do this stuff last, so we queue this FIRST.
            lp.queueWithEntity(ent, function(e)
                lp.addMoney(e, MONEY_PER_ROUND)
                lp.setPointsMult(e, 1)
                lp.setPointsBonus(e, 0)

                local round = lp.getAttribute("ROUND", e)
                local newRound = round + 1
                lp.setRound(e, newRound)

                if hasLost(e) then
                    loseGame(ent.lootplotTeam)
                end
            end)

            resetPlot(ppos)
        end
    end,
})





---@param ppos lootplot.PPos
local function shouldTriggerLevelUp(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and lp.hasTrigger(slot, "LEVEL_UP") then
        return true
    end
    local item = lp.posToItem(ppos)
    if item and lp.hasTrigger(item, "LEVEL_UP") then
        return true
    end
    return false
end


local function getNumberOfRoundsToSkip(ent)
    local round = lp.getRound(ent)
    local numRounds = lp.getNumberOfRounds(ent)
    -- add 1 because it starts at 1
    return (numRounds + 1) - round
end

local function getNumberOfLevelUpTriggerRepeats(ent)
    return getNumberOfRoundsToSkip(ent) + 1
end





local function nextLevel(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end
    local plot = ppos:getPlot()

    local level = lp.getLevel(ent)
    if level >= lp.getNumberOfLevels(ent) then
        winGame(ppos:getPlot())
        return
    end

    umg.analytics.collect("lootplot.s0:completeLevel", {
        playerWinCount = lp.getWinCount(),
        level = lp.getLevel(ent),
        points = lp.getPoints(ent),
        money = lp.getMoney(ent),

        items = getAllItems(plot)
        -- a string list of items on the plot:
        -- {"lootplot.s0:dragonfruit", "lootplot.s0:blueberry", "iron_sword"}
    })

    -- Remember: LIFO!

    lp.queueWithEntity(ent, function(e)
        lp.rawsetAttribute("POINTS", e, 0)
        lp.setRound(e, 1)
        lp.setLevel(e, lp.getLevel(e) + 1)
    end)

    local levelUpTriggerCount = getNumberOfLevelUpTriggerRepeats(ent)

    for _=1, levelUpTriggerCount do
        resetPlot(ppos)

        lp.wait(ppos, 0.1)

        lp.queueWithEntity(ent, function(e)
            lp.Bufferer()
                :all(plot)
                :filter(shouldTriggerLevelUp)
                :withDelay(0.1)
                :to("SLOT_OR_ITEM")
                :execute(function(ppos1, e1)
                    lp.resetCombo(e1)
                    lp.tryTriggerSlotThenItem("LEVEL_UP", ppos1)
                end)
        end)

        resetPlot(ppos)
    end
end




local NEXT_LEVEL_NO_SKIP = interp("Click to go the next level.\n{c r=0.6 g=0.6 b=0.7}(Triggers {lootplot:TRIGGER_COLOR}%{triggerName}{/lootplot:TRIGGER_COLOR} on everything!)")
local NEXT_LEVEL_SKIP_N = interp("Click to skip %{skipCount} rounds, and go the next level.\n{c r=0.6 g=0.6 b=0.7}(Triggers {lootplot:TRIGGER_COLOR}%{triggerName}{/lootplot:TRIGGER_COLOR} on everything {lootplot:INFO_COLOR}%{levelUpTriggerCount} time(s){/lootplot:INFO_COLOR}!)")
local NEXT_LEVEL_NEED_POINTS = interp("{c r=1 g=0.6 b=0.5}Need %{pointsLeft} more points!")

local function nextLevelActivateDescription(ent)
    if umg.exists(ent) then
        local points = lp.getPoints(ent)
        local requiredPoints = lp.getRequiredPoints(ent)
        local pointsLeft = requiredPoints - points
        if pointsLeft <= 0 then
            local skipCount = getNumberOfRoundsToSkip(ent)
            local levelUpTriggerCount = getNumberOfLevelUpTriggerRepeats(ent)
            local triggerName = lp.getTriggerDisplayName("LEVEL_UP")
            if skipCount == 0 then
                return NEXT_LEVEL_NO_SKIP({
                    triggerName = triggerName
                })
            else
                return NEXT_LEVEL_SKIP_N({
                    triggerName = lp.getTriggerDisplayName("LEVEL_UP"),
                    skipCount = skipCount,
                    levelUpTriggerCount = levelUpTriggerCount
                })
            end
        else
            return NEXT_LEVEL_NEED_POINTS({
                pointsLeft = pointsLeft
            })
        end
    end
    return ""
end


local function nextLevelCanActivate(ent)
    local requiredPoints = lp.getRequiredPoints(ent)
    local points = lp.getPoints(ent)
    if points >= requiredPoints then
        return true
    end
    return false
end


lp.defineSlot("lootplot.s0:next_level_button_slot", {
    image = "level_button_up",

    name = loc("Next-Level Button"),
    activateDescription = nextLevelActivateDescription,

    activateAnimation = {
        activate = "level_button_hold",
        idle = "level_button_up",
        duration = 0.1
    },

    baseMaxActivations = 3,
    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.EPIC,

    onDraw = buttonOnDraw,

    canActivate = nextLevelCanActivate,

    onActivate = nextLevel,
})




local NEXT_LEVEL_SIMPLE = loc("Click to go to the next level")

lp.defineSlot("lootplot.s0:simple_next_level_button_slot", {
    --[[
    Exact same as next-level button, but it doesnt allow skipping.
    This keeps the game a bit simpler for newbies.
    ]]
    image = "level_button_up",

    name = loc("Simple Next-Level Button"),
    activateDescription = function(ent)
        if umg.exists(ent) then
            local points = lp.getPoints(ent)
            local requiredPoints = lp.getRequiredPoints(ent)
            local pointsLeft = requiredPoints - points
            if pointsLeft <= 0 then
                return NEXT_LEVEL_SIMPLE
            else
                return NEXT_LEVEL_NEED_POINTS({
                    pointsLeft = pointsLeft
                })
            end
        end
        return ""
    end,

    canActivate = function(ent)
        local level = lp.getLevel(ent) or 0
        local skipCount = getNumberOfRoundsToSkip(ent)
        if (level <= 2) and (skipCount > 0) then
            -- dont allow player to skip the first couple of levels (its a noob-trap)
            return false
        end
        return nextLevelCanActivate(ent)
    end,

    activateAnimation = {
        activate = "level_button_hold",
        idle = "level_button_up",
        duration = 0.1
    },

    baseMaxActivations = 3,
    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.UNIQUE,

    onDraw = buttonOnDraw,

    onActivate = nextLevel,
})




