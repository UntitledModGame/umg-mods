
--[[

==============================
STARTING CURSES
==============================

these are curses that should spawn at the START of a run.
They usually augment the game a lot, and are more than "an annoyance."

Generally, these curses will force a certain playstyle.

]]

local loc = localization.localize


local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end

    lp.defineItem("lootplot.s0:" .. (id), etype)
end



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
        local fogRevealed = plot:isFogRevealed(ppos, team)
        if filterOk and fogRevealed then
            ret:add(slotEnt)
        end
    end)
    return ret
end


local function getSlotsNoButtons(ent, filter)
    return getSlots(ent, function(slotEnt, slotPos)
        if slotEnt.buttonSlot then
            return false
        end
        local filterOk = (not filter) or filter(slotEnt, slotPos)
        return filterOk
    end)
end




local function getItems(ent, filter)
    local ppos = lp.getPos(ent)
    if not ppos then
        return objects.Array()
    end

    local ret = objects.Array()
    ppos:getPlot():foreachItem(function(itemEnt, pos)
        if (not filter) or filter(itemEnt, pos) then
            ret:add(itemEnt)
        end
    end)
    return ret
end





local function getClosestSlot(ent, filter)
    
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



defCurse("aquarium_curse", "Aquarium Curse", {
    description = loc("Whilst this curse exists, {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} cannot go higher than -1."),

    onUpdateServer = function(ent)
        if lp.getPointsBonus(ent) > -1 then
            lp.setPointsBonus(ent, -1)
        end
    end
})



defCurse("cursed_slab", "Cursed Slab", {
    activateDescription = loc("10% chance to transform a random slot into a null-slot"),

    triggers = {"PULSE"},
    onActivate = function(ent)
        local pos, team = getPosTeam(ent)
        if lp.SEED:randomMisc() then
            local slots = getSlotsNoButtons(ent, function(e)
                return e:type() ~= "lootplot.s0:null_slot"
            end)
            executeRandom(slots, function(e,ppos)
                lp.forceSpawnSlot(ppos, server.entities.null_slot, team)
            end)
        end
    end
})



defCurse("cursed_slot_dagger", "Cursed Slot Dagger", {
    activateDescription = loc("Gives {lootplot:DOOMED_COLOR}DOOMED-15{/lootplot:DOOMED_COLOR} to a random slot"),

    triggers = {"PULSE"},
    onActivate = function(ent)
        local pos, team = getPosTeam(ent)
        if lp.SEED:randomMisc() then
            local slots = getSlotsNoButtons(ent, function(e)
                return (not e.doomCount)
            end)
            executeRandom(slots, function(slotEnt,ppos)
                slotEnt.doomCount = 15
            end)
        end
    end
})




local function defTomb(id, name, description, type, func)
    defCurse(id, name, {
        triggers = {"PULSE"},
        activateDescription = description,

        shape = lp.targets.RookShape(6),
        target = {
            type = type,
            activate = func
        }
    })
end


defTomb("tomb_of_item_dooming", "Tomb of Item Dooming",
"Give items {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}", "ITEM", 
function(selfEnt, ppos, targEnt)
    if not targEnt.doomCount then
        targEnt.doomCount = 6
    end
end)

defTomb("tomb_of_slot_dooming", "Tomb of Slot Dooming",
"Give items {lootplot:DOOMED_COLOR}DOOMED-10{/lootplot:DOOMED_COLOR}", "SLOT",
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




local function getRandomCurse()

end


--[[

-- TODO: do something w/ this
defCurse("contract_curse", "Contract Curse", {
    description = loc("Whilst this curse exists, Pie-items and Glove-items are instantly deleted."),

    onUpdateServer = function(ent)
        if math.random() < 0.1 then
            -- 1

        end
    end
})

]]
