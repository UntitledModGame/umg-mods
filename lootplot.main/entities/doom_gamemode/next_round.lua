

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]
local runManager = require("shared.run_manager")

local loc = localization.localize
local interp = localization.newInterpolator

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

        -- Snapshot the run again.
        runManager.saveRun()
    end)

    -- pulse all slots:
    lp.Bufferer()
        :all(plot)
        :to("SLOT_OR_ITEM") -- ppos-->slot
        :execute(function(_ppos, slotEnt)
            lp.resetCombo(slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end


local ROUND_NUM = interp("{wavy amp=0.5 k=0.5}{outline}Round %{round}/%{numberOfRounds}")
local FINAL_ROUND_NUM = interp("{wavy freq=2.5 amp=0.75 k=1}{c r=1 g=0.2 b=0.1}{outline}FINAL ROUND %{round}/%{numberOfRounds}")
local LEVEL_NUM = interp("{wavy amp=0.5 k=0.5}{outline}Level %{level}")

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

        local font = love.graphics.getFont()
        local limit = 0xffff

        local round = lp.main.getRound(ent)
        local numberOfRounds = lp.main.getNumberOfRounds(ent)

        local roundTextMaker = ROUND_NUM
        if round >= numberOfRounds then
            local points = lp.getPoints(ent)
            local requiredPoints = lp.main.getRequiredPoints(ent)

            if points < requiredPoints then
                roundTextMaker = FINAL_ROUND_NUM
            end
        end

        local roundText = roundTextMaker({
            round = round,
            numberOfRounds = numberOfRounds
        })

        local levelText = LEVEL_NUM({
            level = lp.getLevel(ent)
        })
        text.printRichCentered(roundText, font, x, y - 18, limit, "left", rot, sx,sy)
        text.printRichCentered(levelText, font, x, y - 32, limit, "left", rot, sx,sy)
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



local function nextLevel(ent)
    lp.setPoints(ent, 0)
    lp.main.setRound(ent, 1)
    lp.setLevel(ent, lp.getLevel(ent) + 1)
end


local NEXT_LEVEL = loc("Click to progress to the next level!")
local NEED_POINTS = interp("{c r=1 g=0.6 b=0.5}Need %{pointsLeft} more points!")

lp.defineSlot("lootplot.main:next_level_button_slot", {
    image = "level_button_up",

    name = loc("Next-Level Button"),
    activateDescription = function(ent)
        if umg.exists(ent) then
            local points = lp.getPoints(ent)
            local requiredPoints = lp.main.getRequiredPoints(ent)
            local pointsLeft = requiredPoints - points
            if pointsLeft < 0 then
                return NEXT_LEVEL
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


