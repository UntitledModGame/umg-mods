

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]

local constants = require("shared.constants")


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


lp.defineSlot("lootplot.s0:pulse_button_slot", {
    image = "pulse_button_up",

    name = loc("Pulse Button"),
    description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots,\nand go to the next round!"),
    activateDescription = loc("(Afterwards, resets everything, and earns {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR})", {
        money = constants.MONEY_PER_ROUND
    }),

    activateAnimation = {
        activate = "pulse_button_hold",
        idle = "pulse_button_up",
        duration = 0.1
    },

    onDraw = buttonOnDraw,

    baseMaxActivations = 100,

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
                lp.addMoney(e, constants.MONEY_PER_ROUND)
                lp.setPointsMult(e, 1)
                lp.setPointsBonus(e, 0)

                local round = lp.getAttribute("ROUND", e)
                local newRound = round + 1
                lp.setRound(e, newRound)

                if hasLost(e) then
                    lp.loseGame(ent.lootplotTeam)
                    -- destroy all button-slots:
                    deleteAllButtonSlots(plot)
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



lp.defineSlot("lootplot.s0:gray_pulse_button_slot", {
    image = "gray_pulse_button_up",

    name = loc("Gray Button"),
    description = loc("Click to go to the next round."),
    activateDescription = loc("(Afterwards, resets everything, and earns {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR})", {
        money = constants.MONEY_PER_ROUND
    }),

    activateAnimation = {
        activate = "gray_pulse_button_hold",
        idle = "gray_pulse_button_up",
        duration = 0.1
    },

    onDraw = buttonOnDraw,

    baseMaxActivations = 100,

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
                lp.addMoney(e, constants.MONEY_PER_ROUND)
                lp.setPointsMult(e, 1)
                lp.setPointsBonus(e, 0)

                local round = lp.getAttribute("ROUND", e)
                local newRound = round + 1
                lp.setRound(e, newRound)

                if hasLost(e) then
                    lp.loseGame(ent.lootplotTeam)
                    -- destroy all button-slots:
                    deleteAllButtonSlots(plot)
                end
            end)

            resetPlot(ppos)
        end
    end,
})





---@param ppos lootplot.PPos
local function shouldTrigger(ppos)
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

local function nextLevel(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end

    local level = lp.getLevel(ent)
    if level >= constants.FINAL_LEVEL then
        -- oh damn!! GG! :)
        lp.winGame(server.getHostClient())
        deleteAllButtonSlots(ppos:getPlot())
        return
    end

    lp.rawsetAttribute("POINTS", ent, 0)
    lp.setRound(ent, 1)
    lp.setLevel(ent, lp.getLevel(ent) + 1)

    local plot = ppos:getPlot()
    lp.Bufferer()
        :all(plot)
        :filter(shouldTrigger)
        :withDelay(0.4)
        :to("SLOT_OR_ITEM")
        :execute(function(ppos1, e1)
            lp.resetCombo(e1)
            lp.tryTriggerSlotThenItem("LEVEL_UP", ppos1)
        end)
end


local NEXT_LEVEL = interp("Click to progress to the next level! Triggers {lootplot:TRIGGER_COLOR}%{name}{/lootplot:TRIGGER_COLOR} on all items and slots!")
local NEED_POINTS = interp("{c r=1 g=0.6 b=0.5}Need %{pointsLeft} more points!")

lp.defineSlot("lootplot.s0:next_level_button_slot", {
    image = "level_button_up",

    name = loc("Next-Level Button"),
    activateDescription = function(ent)
        if umg.exists(ent) then
            local points = lp.getPoints(ent)
            local requiredPoints = lp.getRequiredPoints(ent)
            local pointsLeft = requiredPoints - points
            if pointsLeft <= 0 then
                return NEXT_LEVEL({name = lp.getTriggerDisplayName("LEVEL_UP")})
            else
                return NEED_POINTS({
                    pointsLeft = pointsLeft
                })
            end
        end
        return ""
    end,

    activateAnimation = {
        activate = "level_button_hold",
        idle = "level_button_up",
        duration = 0.1
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.EPIC,

    onDraw = buttonOnDraw,

    canActivate = function(ent)
        local requiredPoints = lp.getRequiredPoints(ent)
        local points = lp.getPoints(ent)
        if points >= requiredPoints then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            nextLevel(ent)
        end
    end,
})


