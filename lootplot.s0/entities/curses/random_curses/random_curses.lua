
--[[

==============================
RANDOM CURSES
==============================

these are curses that can be spawned in willy-nilly.
They are usually just an annoyance; and wont ruin a run immediately.

]]


local constants = require("shared.constants")

local loc = localization.localize
local interp = localization.newInterpolator

local function defCurse(id, name, etype, spawnBehaviour)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    local curseId = "lootplot.s0:" .. (id)
    lp.defineItem(curseId, etype)

    lp.curses.addSpawnableCurse(curseId, spawnBehaviour)
end



---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getSlots(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    local plot = ppos:getPlot()
    local team = ent.lootplotTeam
    plot:foreachSlot(function(slotEnt, slotPos)
        local filterOk = (not filter) or filter(slotEnt, slotPos)
        local fogRevealed = plot:isFogRevealed(slotPos, team)
        if filterOk and fogRevealed then
            ret:add(slotEnt)
        end
    end)
    return ret
end


---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getSlotsNoButtons(ent, filter)
    return getSlots(ent, function(slotEnt, slotPos)
        if slotEnt.buttonSlot then
            return false
        end
        local filterOk = (not filter) or filter(slotEnt, slotPos)
        return filterOk
    end)
end




---@param ent Entity
---@param filter? fun(ent: Entity, ppos: lootplot.PPos): boolean
---@return objects.Array
local function getItems(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachItem(function(itemEnt, pos)
        local filterOk = ((not filter) or filter(itemEnt, pos))
        local isCurse = lp.curses.isCurse(itemEnt)
        if itemEnt ~= ent and filterOk and (not isCurse) then
            ret:add(itemEnt)
        end
    end)
    return ret
end



local function getCurses(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachItem(function(itemEnt, pos)
        local filterOk = ((not filter) or filter(itemEnt, pos))
        local isCurse = lp.curses.isCurse(itemEnt)
        if itemEnt ~= ent and filterOk and (isCurse) then
            ret:add(itemEnt)
        end
    end)
    return ret
end





-- can be used on arrays of slots, OR arrays of items
local function getClosestEntity(ent, array)
    local ppos = lp.getPos(ent)
    if (not ppos) or (#array <= 0) then
        return
    end
    local bestDist = 0xfffffff
    local bestEnt = nil
    for _, e in ipairs(array) do
        local p = lp.getPos(e)
        if p then
            local dist = math.distance(p:getDifference(ppos))
            if dist < bestDist then
                bestDist = dist
                bestEnt = e
            end
        end
    end
    return bestEnt
end



local function getCurseCount(ent)
    local ppos = lp.getPos(ent)
    if ppos then
        return lp.curses.getCurseCount(ppos:getPlot(), ent.lootplotTeam)
    end
    return 0
end





---@param ent Entity
---@return lootplot.PPos
---@return string
local function getPosTeam(ent)
    return assert(lp.getPos(ent)), ent.lootplotTeam
end



local function executeRandom(arr, func)
    if #arr <= 0 then
        return nil
    end
    local ent = table.random(arr)
    if ent then
        local ppos = lp.getPos(ent)
        if ppos then
            func(ent, ppos)
        end
    end
end



NO_SF = {}
FLOATY_SF = {"FLOATY"}


defCurse("cursed_slab", "Cursed Slab", {
    activateDescription = loc("10% chance to transform a random slot into a null-slot"),

    triggers = {"PULSE"},
    onActivate = function(ent)
        local pos, team = getPosTeam(ent)
        if lp.SEED:randomMisc() <= 0.1 then
            local slots = getSlotsNoButtons(ent, function(e)
                return e:type() ~= "lootplot.s0:null_slot"
            end)
            executeRandom(slots, function(e,ppos)
                lp.forceSpawnSlot(ppos, server.entities.null_slot, team)
            end)
        end
    end
}, NO_SF)



defCurse("cursed_slot_dagger", "Cursed Slot Dagger", {
    activateDescription = loc("Gives {lootplot:DOOMED_COLOR}DOOMED-20{/lootplot:DOOMED_COLOR} to a random slot"),

    triggers = {"PULSE"},
    onActivate = function(ent)
        local slots = getSlotsNoButtons(ent, function(e)
            return (not e.doomCount)
        end)
        executeRandom(slots, function(slotEnt, ppos)
            slotEnt.doomCount = 20
        end)
    end
}, FLOATY_SF)




local function defTomb(id, name, description, type, func)
    defCurse(id, name, {
        triggers = {"PULSE"},
        activateDescription = description,

        shape = lp.targets.RookShape(6),
        target = {
            type = type,
            activate = func
        }
    }, NO_SF)
end


defTomb("tomb_of_item_dooming", "Tomb of Item Dooming",
"Give items {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}", "ITEM", 
function(selfEnt, ppos, targEnt)
    if not targEnt.doomCount then
        targEnt.doomCount = 6
    end
end)

defTomb("tomb_of_slot_dooming", "Tomb of Slot Dooming",
"Give slots {lootplot:DOOMED_COLOR}DOOMED-10{/lootplot:DOOMED_COLOR}", "SLOT",
function(selfEnt, ppos, targEnt)
    if not targEnt.doomCount then
        targEnt.doomCount = 10
    end
end)

defTomb("tomb_of_points", "Tomb of Points",
"Subtract {lootplot:BAD_COLOR}-10 points{/lootplot:BAD_COLOR} from items", "ITEM",
function(selfEnt, ppos, targEnt)
    lp.modifierBuff(targEnt, "pointsGenerated", -10)
end)

defTomb("tomb_of_bonus", "Tomb of Bonus",
"Subtract {lootplot:BAD_COLOR}-2 Bonus{/lootplot:BAD_COLOR} from items", "ITEM",
function(selfEnt, ppos, targEnt)
    lp.modifierBuff(targEnt, "bonusGenerated", -2)
end)

defTomb("tomb_of_multiplier", "Tomb of Multiplier",
"Subtract {lootplot:BAD_COLOR}-0.4 Multiplier{/lootplot:BAD_COLOR} from items", "ITEM",
function(selfEnt, ppos, targEnt)
    lp.modifierBuff(targEnt, "multGenerated", -0.4)
end)

defTomb("tomb_of_money", "Tomb of Money",
"Make slots cost {lootplot:BAD_COLOR}$0.1 extra{/lootplot:BAD_COLOR} to activate", "SLOT",
function(selfEnt, ppos, targEnt)
    lp.modifierBuff(targEnt, "moneyGenerated", -0.1)
end)

defTomb("tomb_of_sticky", "Tomb of Sticky",
"Makes items STICKY", "ITEM",
function(selfEnt, ppos, targEnt)
    targEnt.sticky = true
end)



defCurse("cursed_grubby_coins", "Cursed Grubby Coins", {
    triggers = {"LEVEL_UP"},
    grubMoneyCap = 40,
    basePointsGenerated = -10
}, NO_SF)




defCurse("golden_shivs", "Golden Shivs", {
    activateDescription = loc("Destroys the closest item that costs money to activate."),

    onActivate = function(ent)
        local selfPos, team = getPosTeam(ent)
        if not selfPos then
            return
        end

        local items = getItems(ent, function(itemEnt)
            return itemEnt.moneyGenerated and (itemEnt.moneyGenerated < 0)
        end)
        local closestItem = getClosestEntity(ent, items)
        if closestItem then
            lp.destroy(closestItem)
        end
    end
}, FLOATY_SF)


defCurse("golden_blocks", "Golden Blocks", {
    activateDescription = loc("Destroys the closest money-earning slot."),
    onActivate = function(ent)
        local selfPos, team = getPosTeam(ent)
        if not selfPos then
            return
        end

        local slots = getSlotsNoButtons(ent, function(slotEnt)
            return slotEnt.moneyGenerated and slotEnt.moneyGenerated > 0
        end)
        local closestSlot = getClosestEntity(ent, slots)
        if closestSlot then
            lp.destroy(closestSlot)
        end
    end
}, FLOATY_SF)


defCurse("bankers_helmet", "Bankers Helmet", {
    activateDescription = loc("Makes a random item cost {lootplot:MONEY_COLOR}$0.2{/lootplot:MONEY_COLOR} extra to activate."),
    onActivate = function(ent)
        local items = getItems(ent)
        executeRandom(items, function(targetItem, targetPPos)
            lp.modifierBuff(targetItem, "moneyGenerated", -0.2)
        end)
    end
}, FLOATY_SF)




defCurse("cursed_coin", "Cursed Coin", {
    activateDescription = loc("Steals $0.5 for every other curse on the board."),
    onActivate = function(ent)
        local otherCursesCount = getCurseCount(ent)
        if otherCursesCount > 0 then
            lp.addMoney(ent, -(otherCursesCount * 0.5))
        end
    end
}, NO_SF)


defCurse("mail_curse", "Mail Curse", {
    activateDescription = loc("20% chance to replace {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} trigger with {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} on the closest item."),
    onActivate = function(ent)
        if lp.SEED:randomMisc() > 0.9 then
            return
        end

        local items = getItems(ent, function(itemEnt)
            return lp.hasTrigger(itemEnt, "PULSE")
        end)
        if #items > 0 then
            local item = getClosestEntity(ent, items)
            if item then
                lp.removeTrigger(item, "PULSE")
                lp.addTrigger(item, "LEVEL_UP")
            end
        end
    end,
}, FLOATY_SF)



local function subtractLives(ent, x)
    if ent.lives then
        ent.lives = math.max(0, ent.lives-x)
    end
end
defCurse("heart_leech", "Heart Leech", {
    activateDescription = loc("Removes {lootplot:LIFE_COLOR}4 lives{/lootplot:LIFE_COLOR} from ALL items and slots."),
    onActivate = function(ent)
        for _, itemEnt in ipairs(getItems(ent)) do
            subtractLives(itemEnt, 4)
        end
        for _, slotEnt in ipairs(getSlots(ent)) do
            subtractLives(slotEnt, 4)
        end
    end
}, NO_SF)


local function isFoodItem(ent)
    return lp.hasTag(ent, constants.tags.FOOD)
end

defCurse("bubbling_goo", "Bubbling Goo", {
    activateDescription = loc("Makes a random food-item STUCK."),
    onActivate = function(ent)
        local foodItems = getItems(ent, isFoodItem)
        executeRandom(foodItems, function(item)
            item.stuck = true
        end)
    end
}, NO_SF)




local function isGlassSlot(ent)
    return lp.hasTag(ent, constants.tags.GLASS_SLOT)
end

defCurse("glass_shard", "Glass Shard", {
    activateDescription = loc("Destroys 30% of ALL glass slots."),
    onActivate = function(ent)
        local glassSlots = getSlots(ent, isGlassSlot)
        for _, slotEnt in ipairs(glassSlots) do
            if math.random() <= 0.30 then
                lp.destroy(slotEnt)
            end
        end
    end
}, NO_SF)


defCurse("cursed_life_potion", "Cursed Life Potion", {
    activateDescription = loc("Gives a random curse {lootplot:LIFE_COLOR}+2 lives.{/lootplot:LIFE_COLOR}"),
    onActivate = function(ent)
        local curses = getCurses(ent)
        executeRandom(curses, function(item)
            item.lives = (item.lives or 0) + 2
        end)
    end
}, NO_SF)



defCurse("broken_shield", "Broken Shield", {
    activateDescription = loc("Triggers Pulse on other curse items."),

    shape = lp.targets.KingShape(3),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return lp.curses.isCurse(targEnt)
        end,
        activate = function(selfEnt, ppos, targEnt)
            lp.tryTriggerEntity("PULSE", targEnt)
        end
    }
}, NO_SF)


defCurse("skeleton_cat", "Skeleton Cat", {
    activateDescription = loc("Small chance to clone itself."),

    shape = lp.targets.KNIGHT_SHAPE,

    basePointsGenerated = -50,

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targEnt)
            if lp.SEED:randomMisc() < 0.02 then
                lp.forceCloneItem(selfEnt, ppos)
            end
        end
    }
}, FLOATY_SF)



defCurse("orca_curse", "Orca Curse", {
    activateDescription = loc("Destroys a random {lootplot:INFO_COLOR}FLOATY{/lootplot:INFO_COLOR} item"),

    onActivate = function (ent)
        local items = getItems(ent, function (e, ppos)
            return lp.canItemFloat(e)
        end)
        executeRandom(items, function(itemEnt)
            lp.destroy(itemEnt)
        end)
    end
}, FLOATY_SF)



defCurse("medusa_curse", "Medusa Curse", {
    activateDescription = loc("Transforms a random empty-slot into stone"),

    onActivate = function (ent)
        local slots = getSlotsNoButtons(ent, function (e, ppos)
            return (not lp.posToItem(ppos))
        end)
        executeRandom(slots, function(e, ppos)
            lp.forceSpawnSlot(ppos, server.entities.stone_slot, e.lootplotTeam)
        end)
    end
}, FLOATY_SF)




do
local MONEY_REQ = 100

defCurse("leprechaun_curse", "Leprechaun Curse", {
    activateDescription = loc("If money is greater than {lootplot:MONEY_COLOR}$%{moneyReq}{/lootplot:MONEY_COLOR}, spawn a curse", {
        moneyReq = MONEY_REQ
    }),

    onActivate = function (ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQ then
            local ppos = lp.getPos(ent)
            if ppos then
                lp.curses.spawnRandomCurse(ppos:getPlot(), ent.lootplotTeam)
            end
        end
    end
}, NO_SF)

end



defCurse("cursed_joker_cat", "Cursed Joker Cat", {
    activateDescription = loc("Rotates a random item"),

    triggers = {"PULSE"},
    onActivate = function(ent)
        local items = getItems(ent)
        executeRandom(items, function(e,ppos)
            lp.rotateItem(e, 1)
        end)
    end
}, NO_SF)



