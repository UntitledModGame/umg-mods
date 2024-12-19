
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

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(1),
    doomCount = 1,

    basePrice = 8,
    baseMaxActivations = 1,

    target = {
        type = "SLOT_NO_ITEM",
        description = loc("Spawn RARE items."),
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
    activateDescription = loc("Loses 2 Points-Generated permanently"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 6,
    basePointsGenerated = 60,
    baseMaxActivations = 10,

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
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






defItem("blank_page", {
    name = loc("Blank Page"),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.UP_SHAPE,

    basePrice = 9,
    baseMaxActivations = 10,

    target = {
        type = "ITEM",
        description = loc("Copies Points-Generated of target item"),
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.pointsGenerated then
                selfEnt.basePointsGenerated = targetEnt.pointsGenerated
                -- no need to sync; properties are synced automatically.
            end
        end
    }
})




defItem("map", {
    name = loc("Map"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.CircleShape(6),

    doomCount = 1,
    basePrice = 5,

    target = {
        description = loc("Reveals fog."),
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

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(8),

    doomCount = 3,
    basePrice = 5,

    target = {
        type = "NO_SLOT",
        description = loc("Reveals fog."),
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




defItem("anchor", {
    name = loc("Anchor"),
    activateDescription = loc("Sets points to 0."),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    basePrice = 7,
    baseMaxActivations = 3,
    baseMoneyGenerated = 5,

    onActivate = function(ent)
        lp.setPoints(ent, 0)
    end
})



--[[

TODO: Change this!!!!
its not emergent.

]]
defItem("feather", {
    name = loc("Feather"),

    shape = lp.targets.CircleShape(3),

    basePrice = 8,
    baseMaxActivations = 40,

    rarity = lp.rarities.RARE,

    activateDescription = loc("Spawns a {lootplot:INFO_COLOR}steel-slot{/lootplot:INFO_COLOR} under the item that Pulsed.\n(Only works on floating-items!)"),

    listen = {
        trigger = "PULSE",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnSlot(ppos, server.entities.steel_slot, selfEnt.lootplotTeam)
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

