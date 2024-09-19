

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]

local loc = localization.localize


---@param ent Entity
---@param ppos lootplot.PPos
local function startRound(ent, ppos)
    local plot = ppos:getPlot()

    lp.queue(ppos, function()
        if not umg.exists(ent) then
            -- Next round button is destroyed.
            lp.main.endGame(nil, false)
            return
        end

        -- This will execute LAST.
        plot:foreachLayerEntry(function(ent, ppos, layer)
            lp.reset(ent)
        end)
        lp.addMoney(ent, 8)
    end)

    -- pulse all slots:
    lp.Bufferer()
        :all(plot)
        :to("SLOT") -- ppos-->slot
        :execute(function(_ppos, slotEnt)
            lp.resetCombo(slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end


lp.defineSlot("lootplot.main:next_round_button_slot", {
    image = "start_button_up",

    name = localization.localize("Next round button"),
    description = localization.localize("Click to go to the next round"),

    activateAnimation = {
        activate = "start_button_hold",
        idle = "start_button_up",
        duration = 0.4
    },

    onDraw = function(ent, x, y, rot, sx,sy, kx,ky)
        local font = love.graphics.getFont()
        local limit = 0xffff

        local round, numberOfRounds = lp.main.getRoundInfo()
        local roundText = loc("{wavy amp=0.5 k=0.5}{outline}Round %{round}/%{numberOfRounds}", {
            round = round,
            numberOfRounds = numberOfRounds
        })

        local levelText = loc("{wavy amp=0.5 k=0.5}{outline}Level %{level}", {
            level = lp.levels.getLevel(ent)
        })
        text.printRichCentered(roundText, font, x, y - 18, limit, "left", rot, sx,sy, kx,ky)
        text.printRichCentered(levelText, font, x, y - 32, limit, "left", rot, sx,sy, kx,ky)
    end,

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            startRound(ent, ppos)
        end
    end,
})


