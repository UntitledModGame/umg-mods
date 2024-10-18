local loc = localization.localize

local helper = require("shared.helper")


local COST_TEXT = localization.newInterpolator("{lootplot:MONEY_COLOR}{wavy amp=0.5 k=0.5}{outline}Cost: %{cost}")

return lp.defineSlot("lootplot.s0.content:reroll_button_slot", {

    name = loc("Reroll button"),
    description = loc("Click to reroll!"),

    baseMoneyGenerated = -2,

    onDraw = function(ent, x, y, rot, sx,sy)
        local costTxt = COST_TEXT({
            cost = -(ent.moneyGenerated or 0)
        })
        local font = love.graphics.getFont()
        local limit = 0xffff
        text.printRichCentered(costTxt, font, x, y - 16, limit, "left", rot, sx,sy)
    end,

    lootplotProperties = {
        modifiers = {
            -- rerolls cost $1 more every time button activates
            moneyGenerated = function(ent)
                return -(ent.activationCount or 0)
            end
        }
    },

    image = "reroll_button_up",
    activateAnimation = {
        activate = "reroll_button_hold",
        idle = "reroll_button_up",
        duration = 0.25
    },
    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            helper.rerollPlot(ppos:getPlot())
        end
    end,
})
