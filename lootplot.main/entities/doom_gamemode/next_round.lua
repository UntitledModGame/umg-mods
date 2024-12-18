

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]
local runManager = require("shared.run_manager")

local loc = localization.localize
local interp = localization.newInterpolator

local function fogFilter(ppos, ent)
    local plot = ppos:getPlot()
    return plot:isFogRevealed(ppos, lp.main.PLAYER_TEAM) and lp.hasTrigger(ent, "PULSE")
end

---@param ent Entity
---@param ppos lootplot.PPos
local function startRound(ent, ppos)
    local plot = ppos:getPlot()
    -- Ensure we have the run snapshot before starting round.
    runManager.saveRun()

    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:foreachLayerEntry(function(ent, ppos, layer)
            lp.resetEntity(ent)
        end)
        lp.addMoney(ent, lp.main.constants.MONEY_PER_ROUND)
        lp.setAttribute("POINTS_MUL", ent, 1)

        -- Snapshot the run again.
        runManager.saveRun()
    end)

    -- pulse all slots:
    lp.Bufferer()
        :all(plot)
        :to("SLOT_OR_ITEM") -- ppos-->slot
        :filter(fogFilter)
        :execute(function(_ppos, slotEnt)
            if slotEnt.lootplotTeam ~= lp.main.PLAYER_TEAM then
                return
            end

            lp.resetCombo(slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end


lp.defineSlot("lootplot.main:pulse_button_slot", {
    image = "pulse_button_up",

    name = loc("Pulse Button"),
    description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots,\nand go to the next round!"),
    activateDescription = loc("(When done, triggers {wavy}{lootplot:TRIGGER_COLOR}RESET{/lootplot:TRIGGER_COLOR}{/wavy} on everything, and resets activations.)"),

    activateAnimation = {
        activate = "pulse_button_hold",
        idle = "pulse_button_up",
        duration = 0.25
    },

    onDraw = function(ent, x, y, rot, sx,sy)
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

    baseMaxActivations = 100,

    triggers = {},
    buttonSlot = true,

    canActivate = function(ent)
        local round = lp.main.getRound(ent)
        local numOfRounds = lp.main.getNumberOfRounds(ent)
        if round < (numOfRounds + 1) then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            startRound(ent, ppos)
        end
    end,
})


local function hasLevelUpTrigger(ent)
    for _,t in ipairs(ent.triggers)do
        if t == "LEVEL_UP" then
            return true
        end
    end
    return false
end

---@param ppos lootplot.PPos
local function shouldTrigger(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and hasLevelUpTrigger(slot) then
        return true
    end
    local item = lp.posToItem(ppos)
    if item and hasLevelUpTrigger(item) then
        return true
    end
    return false
end

local function nextLevel(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end

    lp.setPoints(ent, 0)
    lp.main.setRound(ent, 1)
    lp.setLevel(ent, lp.getLevel(ent) + 1)

    local plot = ppos:getPlot()
    lp.Bufferer()
        :all(plot)
        :filter(shouldTrigger)
        :withDelay(0.05)
        :to("SLOT_OR_ITEM")
        :execute(function(ppos, ent)
            lp.resetCombo(ent)
            lp.tryTriggerEntity("LEVEL_UP", ent)
        end)
end


local NEXT_LEVEL = interp("Click to progress to the next level! Triggers {lootplot:TRIGGER_COLOR}%{name}{/lootplot:TRIGGER_COLOR} on all items and slots!")
local NEED_POINTS = interp("{c r=1 g=0.6 b=0.5}Need %{pointsLeft} more points!")

lp.defineSlot("lootplot.main:next_level_button_slot", {
    image = "level_button_up",

    name = loc("Next-Level Button"),
    activateDescription = function(ent)
        if umg.exists(ent) then
            local points = lp.getPoints(ent)
            local requiredPoints = lp.main.getRequiredPoints(ent)
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
        duration = 0.25
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    onDraw = function(ent)
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

    canActivate = function(ent)
        local requiredPoints = lp.main.getRequiredPoints(ent)
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


