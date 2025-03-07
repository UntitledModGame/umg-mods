

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

---@param ent Entity
local function resetPlot(ent, ppos)
    local plot = ppos:getPlot()
    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:foreachLayerEntry(function(e, _ppos, layer)
            lp.resetEntity(e)
        end)
    end)
end


local function pulseWorldLayer(ent, plot)
    plot:foreachLayerEntry(function(e, ppos, layer)
        if layer == "world" then
            lp.tryActivateEntity(e)
        end
    end)
end


lp.defineSlot("lootplot.s0:pulse_button_slot", {
    image = "pulse_button_up",

    name = loc("Pulse Button"),
    description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots,\nand go to the next round!"),
    activateDescription = loc("(Afterwards, resets everything, and earns {lootplot:MONEY_COLOR}%{money}{/lootplot:MONEY_COLOR})", {
        money = constants.MONEY_PER_ROUND
    }),

    activateAnimation = {
        activate = "pulse_button_hold",
        idle = "pulse_button_up",
        duration = 0.1
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

    rarity = lp.rarities.RARE,

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local numOfRounds = lp.getNumberOfRounds(ent)
        if round < (numOfRounds + 1) then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            resetPlot(ent, ppos)

            -- LIFO: we want to reset stuff last, so we queue this FIRST.
            lp.queueWithEntity(ent, function(e)
                lp.addMoney(e, constants.MONEY_PER_ROUND)
                lp.setPointsMult(e, 1)
                lp.setPointsBonus(e, 0)
            end)

            local plot = ppos:getPlot()
            lp.Bufferer()
                :all(plot)
                :to("SLOT_OR_ITEM") -- ppos-->slot
                :filter(fogFilter)
                :execute(function(_ppos, slotEnt)
                    lp.resetCombo(slotEnt)
                    lp.tryTriggerEntity("PULSE", slotEnt)
                end)

            resetPlot(ent, ppos)

            pulseWorldLayer(ent, plot)
            -- ^^^ this needs to be done so the doomClock updates
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
        lp.destroy(ent)
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
        :execute(function(ppos, ent)
            lp.resetCombo(ent)
            lp.tryTriggerEntity("LEVEL_UP", ent)
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

    onDraw = function(ent)
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

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


