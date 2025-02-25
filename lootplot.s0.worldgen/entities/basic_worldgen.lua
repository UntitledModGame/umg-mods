local loc = localization.localize


---@param id string
---@param opts table<string, any>
local function defWorldgenItem(id, opts)
    id = "lootplot.s0.worldgen:" .. id

    opts.rarity = lp.rarities.UNIQUE
    opts.canItemFloat = true
    opts.maxActivations = 1
    opts.doomCount = 1
    opts.triggers = {"PULSE"}
    lp.defineItem(id, opts)
    lp.worldgen.WORLDGEN_ITEMS:add(id)
end



---@param ppos lootplot.PPos
local function generate1x1Island(ppos)
    local slotEnt = server.entities.null_slot()
    local itemEnt = server.entities.chest_epic()
    itemEnt.stuck = true
    lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
end


---@param island lootplot.PPos[]
local function generateGoldIsland(island)
    lp.queue(island[1], function ()
        for _, ppos in ipairs(island) do
            local goldenSlotId = "lootplot.s0:golden_slot"
            local slotEnt = server.entities[goldenSlotId]()
            local islandSize = #island
            if islandSize > 5 then
                slotEnt.doomCount = 2
            elseif islandSize > 2 then
                slotEnt.doomCount = 4
            else
                slotEnt.doomCount = 6
            end
            local itemEnt = nil
            lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
        end
    end)
    lp.wait(island[1], 0.002)
end


defWorldgenItem("basic_worldgen", {
    name = loc("Worldgen Item"),
    description = loc("This is a worldgen item"),

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
        allocator:cullNearbyIslands(3)

        local islands = allocator:generateIslands()
        for _, island in ipairs(islands) do
            if #island > 2 then
                generateGoldIsland(island)
            elseif #island == 1 then
                generate1x1Island(island[1])
            end
        end
    end
})
