local loc = localization.localize


local function defDestructive(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


--[[

TODO:
REWORK DELETED ITEMS:


Dark-skull


death-by-taxes


]]


defDestructive("empty_cauldron", {
    name = loc("Empty Cauldron"),

    triggers = {"DESTROY"},

    rarity = lp.rarities.RARE,
    basePrice = 8,

    shape = lp.targets.RookShape(1),

    onActivate = function(ent)
        local posList = lp.targets.getShapePositions(ent) or {}
        for _,ppos in ipairs(posList) do
            lp.trySpawnSlot(ppos, server.entities.sell_slot, ent.lootplotTeam)
        end
    end,

    target = {
        type = "NO_SLOT",
        description = loc("Spawns a SELL slot."),
    }
})


defDestructive("candle", {
    name = loc("Candle"),
    basePointsGenerated = 5,

    rarity = lp.rarities.EPIC,

    basePrice = 15,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "NO_ITEM",
        description = loc("Clones the below item into target slots with {lootplot:DOOMED_COLOR}DOOMED-1."),
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



defDestructive("tooth_necklace", {
    name = loc("Tooth Necklace"),
    description = loc("Gives slot doomed-6.\nOnly activates if the slot isn't doomed!"),

    baseMaxActivations = 10,
    baseMoneyGenerated = 4,

    basePrice = 4,

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
            slotEnt.doomCount = 6
        end
    end
})



defDestructive("bomb", {
    name = loc("Bomb"),

    rarity = lp.rarities.UNCOMMON,
    doomCount = 1,

    basePrice = 2,

    shape = lp.targets.UnionShape(
        lp.targets.KingShape(1),
        lp.targets.ON_SHAPE
    ),

    target = {
        type = "SLOT",
        description = loc("Destroy target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            -- TODO: Make an explosion animation here...?
            lp.destroy(targetEnt)
        end
    },
})




defDestructive("skull", {
    name = loc("Skull"),

    rarity = lp.rarities.EPIC,
    doomCount = 1,

    basePrice = 4,

    shape = lp.targets.KingShape(1),

    target = {
        type = "NO_ITEM",
        description = loc("Spawns bones"),
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnItem(ppos, server.entities.bone, selfEnt.lootplotTeam)
        end
    },
})

