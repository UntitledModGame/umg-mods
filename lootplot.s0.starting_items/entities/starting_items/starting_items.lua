
local loc = localization.localize
local wg = lp.worldgen


local function definePerk(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float

    id = "lootplot.s0.starting_items:" .. id
    etype = lp.defineItem(id, etype)
    lp.worldgen.STARTING_ITEMS:add(id)
end


---@param ent Entity
---@return lootplot.PPos, string
local function getPosTeam(ent)
    return assert(lp.getPos(ent)), assert(ent.lootplotTeam)
end


local function spawnShop(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(-4,1)), server.entities.shop_slot, 3,2, team)
    wg.spawnSlots(assert(ppos:move(-4, -2)), server.entities.reroll_button_slot, 1,1, team)
end

local function spawnNormal(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(ppos, server.entities.slot, 3,3, team)
end

local function spawnSell(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(0, 3)), server.entities.sell_slot, 3,1, team)
end


-------------------------------------------------------------------

-------------------------------------------------------------------
---  Perk/starter-item definitions:
-------------------------------------------------------------------

-------------------------------------------------------------------


definePerk("one_ball", {
    name = loc("One Ball"),
    description = loc("Gain an extra $4 per turn"),

    baseMoneyGenerated = 4,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnNormal(ent)
        spawnSell(ent)
        wg.spawnSlots(assert(ppos:move(-4, -2)), server.entities.reroll_button_slot, 1,1, team)
    end
})



definePerk("eight_ball", {
    name = loc("Eight Ball"),
    description = loc("Starts with 3 null-slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnNormal(ent)
        spawnSell(ent)
        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.null_slot, 1,3, team)
    end
})



definePerk("four_ball", {
    name = loc("Four Ball"),
    description = loc("Starts with glass-slots instead of normal slots"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnSell(ent)
        wg.spawnSlots(ppos, server.entities.glass_slot, 13,5, team)
    end
})



