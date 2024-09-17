local loc = localization.localize



lp.defineItem("lootplot.content.s0:dark_skull", {
    image = "dark_skull",

    name = loc("Dark Skull"),

    rarity = lp.rarities.UNCOMMON,

    init = function(ent)
        ent.killCount = 0
    end,

    description = function(ent)
        return loc("After destroying {lootplot:BAD_COLOR}{wavy}%{count}{/wavy} items{/lootplot:BAD_COLOR}, spawns a %{rarity} item.", {
            rarity = lp.rarities.LEGENDARY.displayString,
            count = 20 - ent.killCount
        })
    end,

    onActivate = function(selfEnt)
        if selfEnt.killCount > 20 then
            local ppos = lp.getPos(selfEnt)
            lp.destroy(selfEnt)
            if ppos then
                local etype = lp.rarities.randomItemOfRarity(lp.rarities.LEGENDARY, selfEnt)
                    or server.entities[lp.FALLBACK_NULL_ITEM]
                lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    end,

    shape = lp.targets.ABOVE_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            selfEnt.killCount = selfEnt.killCount + 1
            sync.syncComponent(selfEnt, "killCount")
        end
    }
})


lp.defineItem("lootplot.content.s0:death_by_taxes", {
    image = "death_by_taxes",
    name = loc("Death by Taxes"),

    rarity = lp.rarities.COMMON,
    basePrice = 1,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Destroys target item, increases price by 10%."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.multiplierBuff(selfEnt, "price", 1.1, selfEnt)
        end
    }
})


lp.defineItem("lootplot.content.s0:rocks", {
    image = "rocks",
    lootplotProperties = {
        modifiers = {
            -- generates points = 10 * current_level
            pointsGenerated = function(ent)
                local level = lp.getLevel(ent) or 1
                return 10 * level
            end
        }
    },
    name = loc("Rocks"),
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
    basePointsGenerated = 0
})


lp.defineItem("lootplot.content.s0:reaper", {
    image = "reaper",
    name = loc("Reaper"),
    basePointsGenerated = 4,

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Destroy target items, permanently gain +3 points-generated"),
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.modifierBuff(selfEnt, "pointsGenerated", 3)
        end
    },
})


lp.defineItem("lootplot.content.s0:empty_cauldron", {
    image = "empty_cauldron",
    name = loc("Empty Cauldron"),

    triggers = {"DESTROY"},

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    onActivate = function(ent)
        local posList = lp.targets.getTargets(ent) or {}
        for _,ppos in ipairs(posList) do
            lp.trySpawnSlot(ppos, server.entities.sell_slot, ent.lootplotTeam)
        end
    end,

    target = {
        type = "NO_SLOT",
        description = loc("{lootplot.targets:COLOR}Spawns a DESTROY slot."),
    }
})


lp.defineItem("lootplot.content.s0:candle", {
    image = "candle",
    name = loc("Candle"),
    basePointsGenerated = 5,

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "NO_ITEM",
        description = function(selfEnt)
            return loc("{lootplot.targets:COLOR}Clones the below item into target slots with {lootplot:DOOMED_COLOR}DOOMED-1.", selfEnt)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if not selfPos then return end
            local downPos = selfPos:move(0,1)
            local itemEnt = downPos and lp.posToItem(downPos)
            if itemEnt then
                local cloneItem = itemEnt:clone()
                cloneItem.doomCount = 1
                local ok = lp.trySetItem(ppos, cloneItem)
                if not ok then
                    cloneItem:delete() --RIP!
                end
            end
        end
    }
})



lp.defineItem("lootplot.content.s0:tooth_necklace", {
    image = "tooth_necklace",
    name = loc("Tooth Necklace"),
    description = loc("Gives slot doomed-4.\nOnly activates if the slot isn't doomed!"),

    baseMaxActivations = 10,
    baseMoneyGenerated = 4,

    rarity = lp.rarities.UNCOMMON,

    canActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and (not slotEnt.doomCount) then
            return true
        end
    end,

    onActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt then
            slotEnt.doomCount = 4
        end
    end
})



lp.defineItem("lootplot.content.s0:bomb", {
    image = "bomb",
    name = loc("Bomb"),

    rarity = lp.rarities.UNCOMMON,
    doomCount = 1,

    shape = lp.targets.UnionShape(
        lp.targets.KingShape(1),
        lp.targets.ON_SHAPE
    ),

    target = {
        type = "SLOT",
        description = loc("{lootplot.targets:COLOR}Destroy target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            -- TODO: Make an explosion animation here...?
            lp.destroy(targetEnt)
        end
    },
})


