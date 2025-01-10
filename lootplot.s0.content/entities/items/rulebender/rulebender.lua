
local helper = require("shared.helper")

local loc = localization.localize


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



helper.defineDelayItem("gift_box", "Gift Box", {
    name = loc("Gift Box"),

    basePrice = 6,
    baseMaxActivations = 2,

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    delayCount = 25,
    delayDescription = ("Spawn a random %s item")
        :format(lp.rarities.LEGENDARY.displayString),

    delayAction = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        lp.destroy(selfEnt)
        if ppos then
            local etype = lp.rarities.randomItemOfRarity(lp.rarities.LEGENDARY)
                or server.entities[lp.FALLBACK_NULL_ITEM]
            lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})



defItem("pandoras_box", {
    name = loc("Pandora's Box"),
    activateDescription = loc("Spawn RARE items."),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(1),
    doomCount = 1,

    basePrice = 8,
    baseMaxActivations = 1,

    target = {
        type = "SLOT_NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local etype = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
            if etype then
                lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    }
})



defItem("old_brick", {
    name = loc("Old Brick"),
    activateDescription = loc("This item loses {lootplot:POINTS_COLOR}2 Points{/lootplot:POINTS_COLOR} permanently"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 6,
    basePointsGenerated = 40,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
    end
})


defItem("red_brick", {
    name = loc("Red Brick"),
    activateDescription = loc("This item loses {lootplot:POINTS_MULT_COLOR}0.2 Multiplier{/lootplot:POINTS_MULT_COLOR} permanently"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 6,
    baseMultGenerated = 4,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "multGenerated", -0.2)
    end
})





defItem("spear_of_war", {
    name = loc("Spear of War"),
    activateDescription = loc("Generates points equal to the current combo"),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    baseMaxActivations = 25,
    basePointsGenerated = 1,
    basePrice = 9,

    onActivate = function(ent)
        local combo = lp.getCombo(ent)
        if combo then
            local p, mod, mult = properties.computeProperty(ent, "pointsGenerated")
            lp.addPoints(ent, combo * mult)
        end
    end
})





--[[

TODO: Rework this item.
Its current broken due to mult


defItem("blank_page", {
    name = loc("Blank Page"),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.UP_SHAPE,

    basePrice = 9,
    baseMaxActivations = 10,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.pointsGenerated then
                selfEnt.basePointsGenerated = targetEnt.pointsGenerated
                -- no need to sync; properties are synced automatically.
            end
        end
    }
})

]]



defItem("map", {
    name = loc("Map"),
    activateDescription = loc("Reveals fog."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.CircleShape(6),

    doomCount = 1,
    basePrice = 5,

    target = {
        filter = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return not plot:isFogRevealed(ppos, selfEnt.lootplotTeam)
        end,
        activate = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return plot:setFogRevealed(ppos, selfEnt.lootplotTeam, true)
        end
    }
})


defItem("foghorn", {
    name = loc("Fog Horn"),
    activateDescription = loc("Reveals fog."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(8),

    doomCount = 3,
    basePrice = 5,

    target = {
        type = "NO_SLOT",
        filter = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return not plot:isFogRevealed(ppos, selfEnt.lootplotTeam)
        end,
        activate = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return plot:setFogRevealed(ppos, selfEnt.lootplotTeam, true)
        end
    }
})




defItem("feather", {
    name = loc("Feather"),

    shape = lp.targets.QueenShape(3),

    basePrice = 8,

    rarity = lp.rarities.RARE,

    activateDescription = loc("Gives {lootplot:POINTS_MULT_COLOR}+0.5 mult{/lootplot:POINTS_MULT_COLOR} for every targetted floating item."),

    listen = {
        trigger = "PULSE",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.canItemFloat
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addPointsMult(selfEnt, 0.5)
        end
    }
})



defItem("ruby", {
    name = loc("Ruby"),
    activateDescription = loc("Gives {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} to all target items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    manaCost = 1,

    basePrice = 12,
    baseMaxActivations = 5,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.repeatActivations = true
            sync.syncComponent(targetEnt, "repeatActivations")
        end
    }
})



defItem("seraphim", {
    --[[
    TODO:
    this isnt very emergent YET.
    We need more emergent interactions with FLOATY items for this to work better!
    ]]
    name = loc("Seraphim"),
    activateDescription = loc("Gives {lootplot:INFO_COLOR}FLOATY{/lootplot:INFO_COLOR} to all target items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    manaCost = 1,

    basePrice = 12,
    baseMaxActivations = 5,
    canItemFloat = true,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.canItemFloat = true
            sync.syncComponent(targetEnt, "canItemFloat")
        end
    }
})

