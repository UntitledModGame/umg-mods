
local loc = localization.localize



local meows
if client then
    local dirObj = umg.getModFilesystem()
    audio.defineAudioInDirectory(
        dirObj:cloneWithSubpath("entities/items/cats/meows"), {"audio:sfx"}, "lootplot.s0:"
    )
    meows = {
        sound.Sound("lootplot.s0:cat_meow_1", 0.5, 1),
        sound.Sound("lootplot.s0:cat_meow_2", 0.9, 1),
        sound.Sound("lootplot.s0:cat_meow_3", 0.5, 1),
    }
end




local function defineCat(id, etype)
    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    etype.onActivateClient = function(ent)
        local m = table.random(meows)
        m:play(ent, 1, 0.9 + math.random()/5)
    end

    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0:"..id, etype)
end


local function unlockAfterWins(numWins)
    return function()
        return numWins <= lp.getWinCount()
    end
end




defineCat("copycat", {
    name = loc("Copycat"),

    -- I prefer both PULSE and REROLL, because its funny lol.
    -- Also; it makes the game more interesting :)
    triggers = {"PULSE", "REROLL"},

    init = function(ent)
        if lp.SEED:randomMisc()<0.01 then
            ent.image = "copycat_but_cool"
        end
    end,

    rarity = lp.rarities.RARE,

    basePrice = 0,
    baseMaxActivations = 10,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            if (not lp.canItemFloat(selfEnt)) and (not lp.posToSlot(ppos)) then
                return false
            end
            return true
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})



defineCat("dangerously_funny_cat", {
    name = loc("Dangerously Funny Cat"),

    rarity = lp.rarities.RARE,

    basePrice = 0,
    baseMaxActivations = 10,
    basePointsGenerated = 10,

    isEntityTypeUnlocked = unlockAfterWins(2),

    shape = lp.targets.UpShape(1),

    activateDescription = loc("Copies self into target slots, and rotates the copy"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local cloneEnt = lp.tryCloneItem(selfEnt, ppos)
            if cloneEnt then
                lp.rotateItem(cloneEnt, 1)
            end
        end
    }
})




defineCat("chubby_cat", {
    name = loc("Chubby Cat"),

    rarity = lp.rarities.EPIC,

    isEntityTypeUnlocked = unlockAfterWins(3),

    basePrice = 0,
    baseMaxActivations = 10,
    baseMultGenerated = 1,
    sticky = true,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})




defineCat("copykitten", {
    name = loc("Copykitten"),

    rarity = lp.rarities.RARE,

    basePrice = 0,
    baseMaxActivations = 3,
    basePointsGenerated = 5,
    doomCount = 6,

    canItemFloat = true,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        filter = function(selfEnt, ppos)
            if selfEnt.doomCount <= 0 then
                return false
            end
            return true
        end,
        activate = function(selfEnt, ppos, targetEnt)
            if selfEnt.doomCount <= 0 then
                return
            end
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})

defineCat("copykato", {
    name = loc("Copykato"),

    rarity = lp.rarities.RARE,

    isEntityTypeUnlocked = unlockAfterWins(3),

    basePrice = 0,
    baseMoneyGenerated = -2,
    baseMaxActivations = 3,
    basePointsGenerated = 25,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots, and gives {lootplot:POINTS_MOD_COLOR}25 points{/lootplot:POINTS_MOD_COLOR} to the copy!"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos)
            local e = lp.tryCloneItem(selfEnt, ppos)
            if e then
                lp.modifierBuff(e, "pointsGenerated", 25, selfEnt)
            end
        end
    }
})






defineCat("pink_cat", {
    name = loc("Pink Cat"),
    description = loc("Starts with 9 lives"),
    triggers = {"PULSE"},

    isEntityTypeUnlocked = unlockAfterWins(1),

    basePrice = 6,
    baseMaxActivations = 15,
    basePointsGenerated = 10,

    onDraw = function(ent)
        if ent.lives and ent.lives < 1 then
            ent.image = "pink_cat_sad"
        else
            ent.image = "pink_cat"
        end
    end,

    rarity = lp.rarities.RARE,

    lives = 9
})





defineCat("crappy_cat", {
    name = loc("Crappy Cat"),
    activateDescription = loc("Converts target items into a clone of itself"),

    isEntityTypeUnlocked = unlockAfterWins(2),

    rarity = lp.rarities.RARE,

    basePrice = 3,
    baseMaxActivations = 100,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.forceCloneItem(selfEnt, ppos)
        end
    }
})






defineCat("evil_cat", {
    --[[
    lmao this item is kinda troll
    but its FUNNY AF
    ]]
    name = loc("Evil Cat"),

    triggers = {"PULSE", "BUY"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = -3,
    baseMaxActivations = 10,
    baseMultGenerated = -6,
    baseBonusGenerated = 5,
})





do
local PTS_BUFF = 10

defineCat("ball_of_yarn", {
    name = loc("Ball of Yarn"),
    activateDescription = loc("If targetting two items of the same type, give the items {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR}.", {
        buff = PTS_BUFF
    }),

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    baseMaxActivations = 5,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            -- woops, this is quite inefficient, but oh well
            local targs = lp.targets.getTargets(selfEnt)
            if not targs then return false end
            for _, p1 in ipairs(targs) do
                local itemEnt = lp.posToItem(p1)
                if itemEnt and targEnt ~= itemEnt and targEnt:type() == itemEnt:type() then
                    return true
                end
            end
        end,
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "pointsGenerated", PTS_BUFF, selfEnt)
        end
    }
})

end


