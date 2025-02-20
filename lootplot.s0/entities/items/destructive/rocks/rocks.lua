
local loc = localization.localize
local interp = localization.newInterpolator

--[[


Clone rocks: 
Transform into target rocks


Anti-bonus rock, +points (+PULSE)
Anti-bonus rock, +mult (+PULSE)
Anti-bonus rock (+REROLL)

Anti-bonus rock (+UNLOCK, LEVEL_UP)

rock (+ROTATE)

Pro-bonus/income rock: Earns $1, gives +5 bonus

Pro-bonus rock (generates +5 points 10 times)

Grubby Mult rocks, gives +mult, GRUB-10

Golden rocks: Earn $1, give +50 points


]]

local function defRocks(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.baseMaxActivations = 30
    etype.basePrice = 7 -- standard price for rocks

    if not etype.listen then
        etype.triggers = etype.triggers or {"DESTROY"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defRocks("clone_rocks", "Clone Rocks", {
    triggers = {"PULSE", "DESTROY"},

    activateDescription = loc("If item has {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger, transform into a clone of it."),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "DESTROY") and targetEnt:type() ~= selfEnt:type()
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if selfPos then
                lp.forceCloneItem(targetEnt, selfPos)
            end
        end
    }
})

