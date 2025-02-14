
local helper = require("shared.helper")

local loc = localization.localize


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end



helper.defineDelayItem("gift_box", "Gift Box", {
    basePrice = 6,
    baseMaxActivations = 5,

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



defItem("pandoras_box", "Pandora's Box", {
    activateDescription = loc("Spawn RARE items."),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(1),
    doomCount = 1,

    basePrice = 9,
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



defItem("old_brick", "Old Brick", {
    activateDescription = loc("This item loses {lootplot:POINTS_COLOR}2 Points{/lootplot:POINTS_COLOR} permanently"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    basePointsGenerated = 40,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
    end
})




defItem("spear_of_war", "Spear of War", {
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




defItem("void_box", "Void Box", {
    activateDescription = loc("Gives {lootplot:DOOMED_LIGHT_COLOR}+1 doomed{/lootplot:DOOMED_LIGHT_COLOR} to doomed-items"),

    triggers = {"PULSE"},

    baseMaxActivations = 3,
    basePrice = 12,
    baseMoneyGenerated = -8,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.doomCount = (targetEnt.doomCount or 0) + 1
        end,
    },

    rarity = lp.rarities.EPIC,
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



defItem("map", "Map", {
    activateDescription = loc("Reveals fog."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.CircleShape(6),

    doomCount = 1,
    basePrice = 6,

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


defItem("foghorn", "Fog Horn", {
    activateDescription = loc("Reveals fog."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(8),

    doomCount = 3,
    basePrice = 8,

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



defItem("seraphim", "Seraphim", {
    --[[
    TODO:
    this isnt very emergent YET.
    We need more emergent interactions with FLOATY items for this to work better!
    ]]
    activateDescription = loc("Gives {lootplot:INFO_COLOR}FLOATY{/lootplot:INFO_COLOR} to all target items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

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



defItem("prism", "Prism", {
    activateDescription = loc("Decrease round-count by 1."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 16,
    baseMaxActivations = 1,
    doomCount = 8,
    canItemFloat = true,

    lootplotProperties = {
        modifiers = {
            pointsGenerated = function(ent)
                local pointsReq = lp.getRequiredPoints(ent)
                return -math.floor(pointsReq * 0.5)
            end
        }
    },

    onActivate = function(ent)
        lp.modifyAttribute("ROUND", ent, -1)
    end
})

