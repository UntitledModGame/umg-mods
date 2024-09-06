
local function hasRerollTrigger(ppos, ent)
    for _,t in ipairs(ent.triggers)do
        if t == "REROLL" then
            return true
        end
    end
    return false
end



return lp.defineSlot("lootplot.content.s0:reroll_button_slot", {

    name = localization.localize("Reroll button"),
    description = localization.localize("Click to reroll!"),

    baseMoneyGenerated = -2,

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
        duration = 0.4
    },
    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end

        lp.Bufferer()
            :all(ppos:getPlot())
            :to("SLOT") -- ppos-->slot
            :filter(hasRerollTrigger)
            :delay(0.2)
            :execute(function(_ppos, slotEnt)
                lp.resetCombo(slotEnt)
                lp.tryTriggerEntity("REROLL", slotEnt)
            end)
    end,
})
