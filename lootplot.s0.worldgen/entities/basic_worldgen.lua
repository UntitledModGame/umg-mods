local loc = localization.localize

local OFFER_SLOT_BUFF = {
    -- DOOMED-30
    {
        chance = 0.1,
        ---@param itemEnt lootplot.ItemEntity
        handler = function(itemEnt)
            if not itemEnt:hasComponent("doomCount") then
                itemEnt.doomCount = 30
            end
        end
    },
    -- Floating
    {
        chance = 0.1,
        ---@param itemEnt lootplot.ItemEntity
        handler = function(itemEnt)
            if not itemEnt:hasComponent("canItemFloat") then
                itemEnt.canItemFloat = true
            end
        end
    },
    -- REROLL trigger
    {
        chance = 0.1,
        ---@param itemEnt lootplot.ItemEntity
        handler = function(itemEnt)
            if not lp.hasTrigger(itemEnt, "REROLL") then
                local triggers = objects.Array(itemEnt.triggers or {})
                triggers:add("REROLL")
                itemEnt.triggers = triggers
                sync.syncComponent(itemEnt, "triggers")
            end
        end
    },
}


local rarePlusItemGen = nil

---@param team string
---@return lootplot.ItemEntity
local function constructRareOrHigherItem(team)
    if not rarePlusItemGen then
        rarePlusItemGen = lp.newItemGenerator({
            filter = function(item)
                local etype = assert(server.entities[item])
                return
                    etype.rarity and
                    etype.basePrice > 0 and
                    lp.rarities.getWeight(etype.rarity) <= lp.rarities.getWeight(lp.rarities.RARE)
            end
        })
    end

    local itemEType = server.entities[rarePlusItemGen:query() or lp.FALLBACK_NULL_ITEM]
    local itemEnt = itemEType()
    -- We'll set it back to its shared defaults later.
    -- FIXME: Although if volume is set explicity it will lost
    itemEnt.audioVolume = 0
    itemEnt.lootplotTeam = team
    return itemEnt
end

local function setSlotDefaults(slotEnt, team)
    slotEnt.lootplotTeam = team
    -- We'll set it back to its shared defaults later.
    -- FIXME: Although if volume is set explicity it will lost
    slotEnt.audioVolume = 0
end

-- Feel free to modify as needed
-- `weight` is the chance of spawn
-- `handler` must be a function that returns 1 or 2 values: slot and item.
local SPAWNER = {
    -- DOOMED-4 gold slot
    {
        weight = 3,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:golden_slot"]()
            setSlotDefaults(slotEnt, team)
            slotEnt.doomCount = 4
            return slotEnt
        end
    },
    -- DOOMED-4 normal, point-generating slot
    {
        weight = 2,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:slot"]()
            setSlotDefaults(slotEnt, team)
            slotEnt.doomCount = 4
            lp.modifierBuff(slotEnt, "pointsGenerated", 10)
            return slotEnt
        end
    },
    -- Treasure slot
    {
        weight = 2,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:offer_slot"]()
            setSlotDefaults(slotEnt, team)

            local itemEnt = constructRareOrHigherItem(team)
            -- Grant random buff
            for _, tbuff in ipairs(OFFER_SLOT_BUFF) do
                if lp.SEED.worldGenRNG:random() <= tbuff.chance then
                    tbuff.handler(itemEnt)
                end
            end

            return slotEnt, itemEnt
        end
    },
    -- Paper slot
    {
        weight = 2,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:paper_slot"]()
            setSlotDefaults(slotEnt, team)

            local itemEnt = constructRareOrHigherItem(team)
            lp.modifierBuff(itemEnt, "price", lp.SEED.worldGenRNG:random(35, 40))

            return slotEnt, itemEnt
        end
    },
    -- Cloud Slot
    {
        weight = 4,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:cloud_slot"]()
            setSlotDefaults(slotEnt, team)

            local itemEnt = constructRareOrHigherItem(team)
            return slotEnt, itemEnt
        end
    },
    -- Amethyst Slot
    {
        weight = 1,
        ---@param team string
        handler = function(team)
            local slotEnt = server.entities["lootplot.s0.content:amethyst_slot"]()
            setSlotDefaults(slotEnt, team)
            return slotEnt
        end
    }
}

lp.worldgen.defineWorldgen("lootplot.s0.worldgen:basic_worldgen", {
    name = loc("Worldgen Item"),
    description = loc("Never gonna give you the description, never gonna let you look the description."),

    ---@param self lootplot.ItemEntity
    onActivateOnce = function(self)
        -- TODO: Decouple this?
        local selfPPos = assert(lp.getPos(self), "Houston, we have a problem")
        local allocator = lp.worldgen.IslandAllocator(selfPPos:getPlot())
        local sx = (love.math.random() - 0.5) * 4000
        local sy = (love.math.random() - 0.5) * 4000

        local NOISE_PERIOD = 0.5
        local NOISE_THRESHOLD = 0.65
        allocator:map(function(ppos)
            local x, y = ppos:getCoords()
            return love.math.simplexNoise(
                sx + x*NOISE_PERIOD,
                sy + y*NOISE_PERIOD
            ) >= NOISE_THRESHOLD
        end)
        allocator:cullNearbyIslands(4)

        local slotGen = generation.Generator(lp.SEED.worldGenRNG)
        for _, item in ipairs(SPAWNER) do
            slotGen:add(item.handler, item.weight)
        end

        local islands = allocator:generateIslands()
        for _, island in ipairs(islands) do
            if #island >= 3 then
                ---@type fun(team:string):(lootplot.SlotEntity,lootplot.ItemEntity?)
                local islandHandler = slotGen:query()

                lp.queue(island[1], function ()
                    for _, ppos in ipairs(island) do
                        local slotEnt, itemEnt = islandHandler(self.lootplotTeam)
                        lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
                    end
                end)
                lp.wait(island[1], 0.02)
            end
        end
    end
})
