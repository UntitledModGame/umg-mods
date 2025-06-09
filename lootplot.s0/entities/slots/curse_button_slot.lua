
local loc = localization.localize



lp.defineSlot("lootplot.s0:curse_button_slot", {
    image = "curse_button_up",

    name = loc("Curse Button"),
    activateDescription = loc("Spawns a random Curse somewhere!"),

    activateAnimation = {
        activate = "curse_button_hold",
        idle = "curse_button_up",
        duration = 0.1
    },

    baseMaxActivations = 20,
    baseMoneyGenerated = 25,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.LEGENDARY,

    onDraw = function(ent)
        -- NOTE: this is a bit weird/hacky, 
        -- since we aren't actually drawing anything..
        -- but its "fine"
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            lp.curses.spawnRandomCurse(ppos:getPlot(), ent.lootplotTeam)
        end
    end,
})


