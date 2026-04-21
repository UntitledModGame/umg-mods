
local loc = localization.localize


lp.defineSlot("lootplot.s0:death_button_slot", {
    image = "death_button_up",

    name = loc("Death Button"),
    activateDescription = loc("Destroys a random item"),

    activateAnimation = {
        activate = "death_button_hold",
        idle = "death_button_up",
        duration = 0.1
    },

    baseMaxActivations = 3,
    baseMoneyGenerated = 6,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.RARE,

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
        if not ppos then return end
        local buf = objects.Array()
        ppos:getPlot():foreachItem(function (ient, _ppos)
            buf:add(ient)
        end)
        local itemEnt = table.random(buf)
        if itemEnt and lp.isItemEntity(itemEnt) then
            lp.destroy(itemEnt)
        end
    end,
})


