
--[[

==============================
INJUNCTION CURSES
==============================

Injunction curses should spawn at the START of a run.
Usually disables a certain playstyle.


- All slots without DOOMED are given DOOMED-25
- Null-slots get turned to stone
- Glass-slots get turned to stone
- Basic-slots get turned to dirt
- All items with Repeater get transformed into manure
- All items with Grubby get transformed into manure
- All items with Destroy trigger get transformed into manure
- All items with Rotate trigger get transformed into manure
- All items with Reroll trigger get transformed into manure
- All items that earn bonus get transformed into manure
- All items that subtract bonus get transformed into manure
- All items that earn money get transformed into manure

- All items with a modified {col}shape{/col} get transformed into manure
- All items with modified {col}triggers{/col} get transformed into manure
- Subtract -1 activations from ALL items (cannot go below 1)


]]

local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")



local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = etype.image or "injunction_curse"
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}

    etype.isInvincible = function(ent)
        return true
    end

    etype.lootplotTags = {constants.tags.INJUNCTION_CURSE}

    etype.baseMaxActivations = etype.baseMaxActivations or 4

    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end

    lp.defineItem("lootplot.s0:" .. (id), etype)
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



defCurse("doomed_injunction", "Doomed Injunction", {
    activateDescription = loc("All slots without {lootplot:DOOMED_LIGHT_COLOR}DOOMED{/lootplot:DOOMED_LIGHT_COLOR} are given {lootplot:DOOMED_LIGHT_COLOR}DOOMED-25{/lootplot:DOOMED_LIGHT_COLOR}"),

    doomCount = 999,

    onActivate = function(ent)
        local slots = getSlotsNoButtons(ent, function(e, ppos)
            return not e.doomCount
        end)
        for _,s in ipairs(slots) do
            s.doomCount = 25
        end
    end
})



defCurse("null_slot_injunction", "Null Slot Injunction", {
    activateDescription = loc("All Null-Slots get turned to stone"),

    color = {0.8,0.8,0.8},

    onActivate = function(ent)
        local team = ent.lootplotTeam
        local slots = getSlots(ent, function(e, ppos)
            return e:type() == "lootplot.s0:null_slot"
        end)
        for _,s in ipairs(slots)do
            local pp = lp.getPos(s)
            if pp then lp.forceSpawnSlot(pp, server.entities.stone_slot, team) end
        end
    end
})


defCurse("glass_slot_injunction", "Glass Slot Injunction", {
    activateDescription = loc("All Glass-Slots get turned to stone"),

    color = {1,1,1,0.5},

    onActivate = function(ent)
        local team = ent.lootplotTeam
        local slots = getSlots(ent, function(e, ppos)
            return lp.hasTag(e, constants.tags.GLASS_SLOT)
        end)
        for _,s in ipairs(slots)do
            local pp = lp.getPos(s)
            if pp then lp.forceSpawnSlot(pp, server.entities.stone_slot, team) end
        end
    end
})



defCurse("basic_slot_injunction", "Basic Slot Injunction", {
    activateDescription = loc("All Basic-slots get turned into dirt"),

    onActivate = function(ent)
        local team = ent.lootplotTeam
        local slots = getSlots(ent, function(e, ppos)
            return lp.hasTag(e, constants.tags.BASIC_SLOT)
        end)
        for _,s in ipairs(slots)do
            local pp = lp.getPos(s)
            if pp then lp.forceSpawnSlot(pp, server.entities.dirt_slot, team) end
        end
    end
})




---@param ent Entity
---@param f fun(itemEnt: Entity, ppos: lootplot.PPos)
local function foreachItem(ent, f)
    local items = getItems(ent)
    for _, item in ipairs(items) do
        local ppos = lp.getPos(item)
        if ppos then
            f(item, ppos)
        end
    end
end



lp.defineItem("lootplot.s0:manure", {
    image = "manure",
    name = loc("Manure"),
    rarity = lp.rarities.UNIQUE,
    triggers = {"PULSE"},
    basePointsGenerated = -1,
})




local function spawnManure(ppos, team)
    lp.forceSpawnItem(ppos, server.entities.manure, team)
end


defCurse("repeater_injunction", "Repeater Injunction", {
    activateDescription = loc("All items with {lootplot:REPEATER_COLOR}Repeater{/lootplot:REPEATER_COLOR} get transformed into manure"),

    repeatActivations = true,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if itemEnt.repeatActivations then
                spawnManure(ppos, team)
            end
        end)
    end
})



defCurse("anti_grubby_injunction", "Anti Grubby Injunction", {
    activateDescription = loc("All items with {lootplot:GRUB_COLOR_LIGHT}Grubby{/lootplot:GRUB_COLOR_LIGHT} get transformed into manure"),

    grubMoneyCap = 1000,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if itemEnt.grubMoneyCap then
                spawnManure(ppos, team)
            end
        end)
    end
})



defCurse("pulse_injunction", "Pulse Injunction", {
    activateDescription = loc("All items with {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} trigger become {lootplot:STUCK_COLOR}STICKY{/lootplot:STUCK_COLOR}"),

    onActivate = function(ent)
        foreachItem(ent, function(itemEnt, ppos)
            if lp.hasTrigger(itemEnt, "PULSE") then
                itemEnt.sticky = true
            end
        end)
    end
})


defCurse("destroy_injunction", "Destroy Injunction", {
    activateDescription = loc("All items with {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger get transformed into manure"),

    color = {0.5,0.5,0.5},

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if lp.hasTrigger(itemEnt, "DESTROY") then
                spawnManure(ppos, team)
            end
        end)
    end
})


defCurse("rotate_injunction", "Rotate Injunction", {
    activateDescription = loc("All items with {lootplot:TRIGGER_COLOR}Rotate{/lootplot:TRIGGER_COLOR} trigger get transformed into manure"),

    color = lp.targets.TARGET_COLOR,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if lp.hasTrigger(itemEnt, "ROTATE") then
                spawnManure(ppos, team)
            end
        end)
    end
})



defCurse("reroll_injunction", "Reroll Injunction", {
    activateDescription = loc("All items with {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} trigger get transformed into manure"),

    color = objects.Color.GREEN,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if lp.hasTrigger(itemEnt, "REROLL") then
                spawnManure(ppos, team)
            end
        end)
    end
})



defCurse("bonus_injunction", "Bonus Injunction", {
    activateDescription = loc("All items that earn {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} get transformed into manure"),

    color = objects.Color.CYAN,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if ((itemEnt.bonusGenerated or 0) > 0) then
                spawnManure(ppos, team)
            end
        end)
    end
})



defCurse("anti_bonus_injunction", "Anti Bonus Injunction", {
    activateDescription = loc("All items that subtract {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} get transformed into manure"),

    color = objects.Color.BLUE,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if ((itemEnt.bonusGenerated or 0) < 0) then
                spawnManure(ppos, team)
            end
        end)
    end
})





defCurse("grubby_injunction", "Grubby Injunction", {
    basePointsGenerated = -5,
    grubMoneyCap = 15,
})





defCurse("capital_injunction", "Capital Injunction", {
    activateDescription = loc("All items that earn {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} get transformed into manure"),

    color = lp.COLORS.MONEY_COLOR,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            if ((itemEnt.baseMoneyGenerated or 0) < 0) then
                spawnManure(ppos, team)
            end
        end)
    end
})




defCurse("shape_injunction", "Shape Injunction", {
    activateDescription = loc("All items whose {lootplot.targets:COLOR}targets{/lootplot.targets:COLOR} have been modified get transformed into manure.\n(Eg. with pies or gloves)"),

    color = lp.targets.TARGET_COLOR,

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            local etype = itemEnt:getEntityType()
            local shape = itemEnt.shape and itemEnt.shape.relativeCoords
            local oldShape = etype.shape and etype.shape.relativeCoords
            if shape and (#shape ~= #oldShape) then
                -- gotcha!!! its a different shape. Die!
                spawnManure(ppos, team)
            end
        end)
    end
})





---Returns true iff arr1 and arr2 have the same elements
---@param arr1 any
---@param arr2 any
local function setEqual(arr1, arr2)
    local set2 = objects.Set(arr2)
    if #arr1 ~= #arr2 then
        return false
    end
    for _, a in ipairs(arr1) do
        if not set2:has(a) then
            return false
        end
    end
    return true
end


defCurse("trigger_injunction", "Trigger Injunction", {
    activateDescription = loc("All items whose {lootplot:TRIGGER_COLOR}Triggers{/lootplot:TRIGGER_COLOR} have been modified get transformed into manure"),

    onActivate = function(ent)
        local team = assert(ent.lootplotTeam)
        foreachItem(ent, function(itemEnt, ppos)
            local etype = itemEnt:getEntityType()
            if not setEqual(etype.triggers, itemEnt.triggers) then
                spawnManure(ppos, team)
            end
        end)
    end
})




defCurse("activation_injunction", "Activation Injunction", {
    activateDescription = loc("If ANY item has more than (3/3) {lootplot:TRIGGER_COLOR}activations{/lootplot:TRIGGER_COLOR}, subtract 1 activation from that item."),

    onActivate = function(ent)
        foreachItem(ent, function(itemEnt, ppos)
            if ((itemEnt.maxActivations or 0) > 3) then
                lp.modifierBuff(itemEnt, "maxActivations", -1, ent)
            end
        end)
    end
})


