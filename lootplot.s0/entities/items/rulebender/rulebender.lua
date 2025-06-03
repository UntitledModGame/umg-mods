
local helper = require("shared.helper")

local loc = localization.localize


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end




defItem("gift_box", "Gift Box", {
    basePrice = 10,
    baseMaxActivations = 2,
    baseMultGenerated = 0.8,

    unlockAfterWins = 4,

    triggers = {"PULSE"},

    activateDescription = loc("4% chance to turn into a %{LEGENDARY} chest", {
        LEGENDARY = lp.rarities.LEGENDARY.displayString
    }),

    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos and lp.SEED:randomMisc() <= 0.4 then
            local itemEnt = lp.forceSpawnItem(ppos, server.entities.chest_legendary, selfEnt.lootplotTeam)
            if itemEnt then
                itemEnt.stuck = true
            end
        end
    end,

    rarity = lp.rarities.RARE,
})



defItem("pandoras_box", "Pandora's Box", {
    activateDescription = loc("Spawn RARE items."),

    unlockAfterWins = 4,

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


do
local DEBUFF = 15

defItem("old_brick", "Old Brick", {
    activateDescription = loc("This item loses {lootplot:POINTS_COLOR}%{debuff} Points{/lootplot:POINTS_COLOR} permanently", {
        debuff = DEBUFF
    }),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    basePointsGenerated = DEBUFF * 20,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -DEBUFF)
    end
})

end



defItem("spear_of_war", "Spear of War", {
    activateDescription = loc("Generates {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} equal to the current combo"),

    unlockAfterWins = 4,

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    baseMaxActivations = 6,
    baseMoneyGenerated = -1,
    basePrice = 19,

    onActivate = function(ent)
        local combo = lp.getCombo(ent)
        if combo then
            lp.addPointsMult(ent, combo)
        end
    end
})




defItem("void_box", "Void Box", {
    activateDescription = loc("Gives {lootplot:DOOMED_LIGHT_COLOR}+1 doomed{/lootplot:DOOMED_LIGHT_COLOR} to doomed-items"),

    unlockAfterWins = 5,

    triggers = {"PULSE"},

    baseMaxActivations = 3,
    basePrice = 12,
    baseMoneyGenerated = -6,

    shape = lp.targets.HorizontalShape(1),
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




defItem("toilet_paper", "Toilet Paper", {
    triggers = {"PULSE"},

    unlockAfterWins = 2,

    baseMaxActivations = 10,
    basePrice = 12,
    basePointsGenerated = -50,
    baseMultGenerated = -10,
    baseMoneyGenerated = 1,

    rarity = lp.rarities.RARE,
})




defItem("basilisks_eye", "Basilisk's Eye", {
    activateDescription = loc("Set rarity of items/slots to %{UNCOMMON}", {
        UNCOMMON = lp.rarities.UNCOMMON.displayString
    }),

    unlockAfterWins = 1,

    triggers = {"PULSE"},

    baseMaxActivations = 10,
    basePointsGenerated = 20,
    basePrice = 7,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.rarity ~= lp.rarities.UNCOMMON
        end,
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.rarity = lp.rarities.UNCOMMON
            sync.syncComponent(targetEnt, "rarity")
        end,
    },

    rarity = lp.rarities.RARE,
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

    shape = lp.targets.CircleShape(8),

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

    canItemFloat = true,

    shape = lp.targets.QueenShape(8),

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




---@param plot lootplot.Plot
---@return lootplot.ItemEntity?
local function getRandomPlotItem(plot)
    local arr = objects.Array()
    plot:foreachItem(function(itemEnt, ppos)
        arr:add(itemEnt)
    end)
    if #arr > 0 then
        return table.random(arr)
    end
end

defItem("magic_wand", "Magic Wand", {
    activateDescription = loc("Transform items into a clone of a random item on the plot."),

    triggers = {"PULSE"},

    unlockAfterWins = 6,

    rarity = lp.rarities.EPIC,

    basePrice = 16,
    baseMaxActivations = 10,

    shape = lp.targets.NorthEastShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local plot = ppos:getPlot()
            local itemEnt = getRandomPlotItem(plot)
            if itemEnt then
                lp.forceCloneItem(itemEnt, ppos)
            end
        end
    }
})




defItem("seraphim", "Seraphim", {
    --[[
    TODO:
    this isnt very emergent YET.
    We need more emergent interactions with FLOATY items for this to work better!
    ]]
    activateDescription = loc("Gives {lootplot:INFO_COLOR}FLOATY{/lootplot:INFO_COLOR} to items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 12,
    baseMaxActivations = 1,
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

    rarity = lp.rarities.UNIQUE,

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




--[[

TODO: 
Changed paperclip --> bandage

]]




do
local NUM_LIVES = 2

defItem("bandage", "Bandage", {
    activateDescription = loc("Gives {lootplot:LIFE_COLOR}+%{lives} lives{/lootplot:LIFE_COLOR} to slots.", {
        lives = NUM_LIVES
    }),

    unlockAfterWins = 4,

    triggers = {"PULSE"},

    rarity = lp.rarities.EPIC,

    basePrice = 8,
    baseMaxActivations = 5,
    baseMultGenerated = 0.8,

    shape = lp.targets.ON_SHAPE,

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + NUM_LIVES
        end
    }
})
end


