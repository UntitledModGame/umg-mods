
local loc = localization.localize
local interp = localization.newInterpolator



local function defDestructive(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


--[[

TODO:
REWORK DELETED ITEMS:


Dark-skull

]]


defDestructive("empty_cauldron", {
    name = loc("Empty Cauldron"),

    triggers = {"DESTROY"},

    rarity = lp.rarities.RARE,
    basePrice = 8,
    baseMaxActivations = 1,

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

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 15,
    baseMaxActivations = 1,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "SLOT_NO_ITEM",
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

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 1,

    rarity = lp.rarities.UNCOMMON,
    shape = lp.targets.ON_SHAPE,

    target = {
        type = "SLOT",
        description = loc("Gives slot {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}, and earn {lootplot:MONEY_COLOR}4${/lootplot:MONEY_COLOR}.\nOnly activates if the slot isn't doomed!"),
        activate = function(ent, ppos, slotEnt)
            lp.addMoney(ent, 4)
            slotEnt.doomCount = 6
        end,
        filter = function(ent, ppos, slotEnt)
            if slotEnt and (not slotEnt.doomCount) then
                return true
            end
        end,
    }
})



defDestructive("bomb", {
    name = loc("Bomb"),

    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,
    doomCount = 1,

    basePrice = 2,
    baseMaxActivations = 1,

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




defDestructive("goblet_of_blood", {
    name = loc("Goblet of Blood"),

    triggers = {"PULSE"},

    rarity = lp.rarities.EPIC,
    doomCount = 10,

    basePointsGenerated = 1,

    activateDescription = loc("Doubles its own points-generated!"),

    basePrice = 8,
    baseMaxActivations = 10,

    listen = {
        trigger = "DESTROY",
        activate = function(selfEnt, ppos, targetEnt)
            local points = selfEnt.pointsGenerated
            lp.modifierBuff(selfEnt, "pointsGenerated", points, selfEnt)
        end,
    },

    shape = lp.targets.LARGE_KING_SHAPE,
})



defDestructive("pink_mitten", {
    name = loc("Pink Mitten"),

    triggers = {"PULSE"},

    onActivate = function(ent)
        ent.lives = (ent.lives or 0) + 1
    end,

    rarity = lp.rarities.RARE,
    basePrice = 1,

    activateDescription = loc("Gains {lootplot:LIFE_COLOR}+1 life{/lootplot:LIFE_COLOR}\n(Maximum of 15)")
})




--[[

TODO:
Do something with this.

defDestructive("dark_skull", {
    name = loc("Dark Skull"),

    rarity = lp.rarities.EPIC,

    basePrice = 12,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        description = loc("Spawns rocks"),
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnItem(ppos, server.entities.rock, selfEnt.lootplotTeam)
        end
    },
})

]]
