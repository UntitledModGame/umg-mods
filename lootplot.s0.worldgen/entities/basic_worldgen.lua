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
---@param team string
local function spawnChest(ppos, team)
    local slotEnt = server.entities.null_slot()
    slotEnt.lootplotTeam = team
    local itemEnt = server.entities.chest_epic()
    itemEnt.stuck = true
    itemEnt.lootplotTeam = team
    lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
end




local function spawnIncomeSlot(ppos, team, islandSize)
    local slotId = "lootplot.s0:slot"
    local slotEnt = server.entities[slotId]()
    slotEnt.baseMoneyGenerated = 1
    slotEnt.lootplotTeam = team

    if islandSize > 5 then
        slotEnt.doomCount = 2
    elseif islandSize > 2 then
        slotEnt.doomCount = 3
    else
        slotEnt.doomCount = 4
    end
    local itemEnt = nil

    lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
end


local function spawnOfferSlot(ppos, team)
    local slotEnt = server.entities["lootplot.s0:offer_slot"]()
    slotEnt.lootplotTeam = team

    local rar = ((lp.SEED:randomWorldGen() < 0.85) and lp.rarities.EPIC) or lp.rarities.LEGENDARY
    local itemType = lp.rarities.randomItemOfRarity(rar)
    local itemEnt = itemType and itemType()
    if itemEnt then
        itemEnt.lootplotTeam = team
        lp.unlocks.forceSpawnLockedSlot(ppos, slotEnt, itemEnt)
    else
        umg.log.error("Waht the HECK. why didnt it spawn??", itemType)
    end
end


---@param island lootplot.PPos[]
---@param team string
local function generateBigIsland(island, team)
    lp.queue(island[1], function ()
        local islandSize = #island
        for _, ppos in ipairs(island) do
            if lp.SEED:randomWorldGen() < 0.5 then
                spawnIncomeSlot(ppos, team, islandSize)
            else
                spawnOfferSlot(ppos, team)
            end
        end
    end)
    lp.wait(island[1], 0.002)
end



defWorldgenItem("basic_worldgen", {
    name = loc("Worldgen Item"),
    description = loc("This is a worldgen item"),

    ---@param self lootplot.ItemEntity
    onActivateOnce = function(self)
        local team = self.lootplotTeam

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
                generateBigIsland(island, team)
            elseif #island == 1 then
                if lp.SEED:randomWorldGen() < 0.5 then
                    spawnOfferSlot(island[1], team)
                else
                    spawnChest(island[1], team)
                end
            end
        end
    end
})
