
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
    wg.spawnSlots(assert(ppos:move(0, 3)), server.entities.sell_slot, 1,1, team)
end

local function spawnMoneyLimit(ent)
    local ppos, team = getPosTeam(ent)
    wg.spawnSlots(assert(ppos:move(4, -4)), server.entities.money_limit_slot, 1,1, team)
end

-------------------------------------------------------------------

-------------------------------------------------------------------
---  Perk/starter-item definitions:
-------------------------------------------------------------------

-------------------------------------------------------------------

local TUTORIAL_1_TEXT = loc("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}WASD / Right click\nto move around{/outline}{/wavy}")
local TUTORIAL_2_TEXT = loc("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}Click to interact\n\nScroll mouse to\nzoom in/out{/outline}{/wavy}")

umg.defineEntityType("lootplot.s0.starting_items:tutorial_text", {
    lifetime = 50,

    onUpdateServer = function(ent)
        local run = lp.main.getRun()
        if run and run:getAttribute("ROUND") > 1 then
            ent:delete()
        end
    end,

    onUpdateClient = function(ent)
        local run = lp.main.getRun()
        if run then
            local plot = run:getPlot()
            local pos = plot:getPPos(ent.pposX, ent.pposY):getWorldPos()
            ent.x, ent.y = pos.x, pos.y
        end
    end,
})

---@param ppos lootplot.PPos
---@param text table
local function spawnTutorialText(ppos, text)
    local textEnt = server.entities.tutorial_text()
    textEnt.text = text
    textEnt.pposX, textEnt.pposY = ppos:getCoords()
    return textEnt
end

---@param ent Entity
---@param name string
local function removeTutorialText(ent, name)
    local e = ent[name]
    if e then
        if umg.exists(e) then
            e:delete()
        end

        ent[name] = nil
    end
end

definePerk("one_ball", {
    name = loc("One Ball"),
    description = loc("Gain an extra $4 per turn"),

    baseMoneyGenerated = 4,
    baseMaxActivations = 1,

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnNormal(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)
        wg.spawnSlots(assert(ppos:move(-4, -2)), server.entities.reroll_button_slot, 1,1, team)

        -- Display tutorial text
        spawnTutorialText(assert(ppos:move(0, -3)), {
            text = TUTORIAL_1_TEXT,
            align = "center",
            oy = 10
        })
        spawnTutorialText(assert(ppos:move(3, 0)), {
            text = TUTORIAL_2_TEXT,
            align = "left"
        })
    end,

    onActivate = function(ent)
        -- Remove tutorial text once this has been activated twice.
        if ent.totalActivationCount >= 2 then
            removeTutorialText(ent, "tutorial1")
            removeTutorialText(ent, "tutorial2")
        end
    end
})



definePerk("nine_ball", {
    name = loc("Nine Ball"),
    description = loc("Lose $1 per turn. Has no money limit."),

    baseMoneyGenerated = -2,
    baseMaxActivations = 1,

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
        spawnMoneyLimit(ent)
        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.null_slot, 1,3, team)
    end
})



definePerk("fourteen_ball", {
    name = loc("Fourteen Ball"),
    description = loc("Spawns with a lockable shop, and a reroll-slot"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)
        wg.spawnSlots(assert(ppos:move(-4,1)), server.entities.lockable_shop_slot, 3,2, team)
        wg.spawnSlots(assert(ppos:move(-4, -2)), server.entities.reroll_button_slot, 1,1, team)

        wg.spawnSlots(assert(ppos:move(3, 0)), server.entities.reroll_slot, 1,1, team)

        spawnSell(ent)
        spawnNormal(ent)
        spawnMoneyLimit(ent)
    end
})





definePerk("four_ball", {
    name = loc("Four Ball"),
    description = loc("Starts with glass-slots instead of normal slots"),
    --[[
    TODO: this starting-item is MEGA-LAME.
    Replace it with something better.
    ]]

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)
        wg.spawnSlots(ppos, server.entities.glass_slot, 13,5, team)
    end
})




definePerk("bowling_ball", {
    --[[
    TODO:

    do something more interesting with this.
    I was thinking of even creating a UNIQUE item-type; `bowling-pin`,
    that this item spawns with?
    Perhaps bowling-pins can be used to customize starting plot...?
    ]]
    name = loc("Bowling Ball"),
    description = loc("CHALLENGE-ITEM: TODO"),

    onActivateOnce = function(ent)
        local ppos, team = getPosTeam(ent)

        spawnShop(ent)
        spawnSell(ent)
        spawnMoneyLimit(ent)
        wg.spawnSlots(ppos, server.entities.glass_slot, 13,5, team)
    end
})


