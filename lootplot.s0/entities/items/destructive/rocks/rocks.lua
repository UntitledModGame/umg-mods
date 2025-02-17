
local loc = localization.localize
local interp = localization.newInterpolator


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

