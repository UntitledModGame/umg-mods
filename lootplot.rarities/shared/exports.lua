
local RARITY_CTX = {context = "This is name of a rarity, keep it uppercase"}

---@alias lootplot.rarities.Rarity {id:string, color:objects.Color, index:number, name:string, rarityWeight:number, displayString:string}
---@return lootplot.rarities.Rarity
local function newRarity(id, name, rarity_weight, color)
    local rarityDisplayName = localization.localize(name, nil, RARITY_CTX)
    local cStr = string.format("{wavy}{c r=%f g=%f b=%f}%s{/c}{/wavy}", color.r, color.g, color.b, rarityDisplayName)

    local rarity = {
        id = id,
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight,
        displayString = cStr
    }

    umg.register(rarity, "lootplot.rarities:" .. name)
    return rarity
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end




if client then
    umg.on("lootplot:populateDescriptionTags", function(ent, arr)
        local rarity = ent.rarity
        if rarity then
            ---@cast rarity lootplot.rarities.Rarity
            arr:add(rarity.displayString)
        end
    end)
end



---Can override rarities in this table:
---
---Availability: Client and Server
lp.rarities = {
    -- rarities for "normal" items
    COMMON = newRarity("COMMON", "COMMON (I)", 2, hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON", "UNCOMMON (II)", 1.5, objects.Color("#" .. "FF40B49B")),
    RARE = newRarity("RARE", "RARE (III)", 1, hsl(220, 90, 55)),
    EPIC = newRarity("EPIC", "EPIC (IV)", 0.6, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY", "LEGENDARY (V)",0.1, hsl(330, 100, 35)),
    MYTHIC = newRarity("MYTHIC", "MYTHIC (VI)", 0.02, hsl(50, 90, 40)),

    -- Use this rarity when you dont want an item to spawn naturally.
    -- (Useful for easter-egg items, or items that can only be spawned by other items)
    UNIQUE = newRarity("UNIQUE", "UNIQUE", 0.00, objects.Color.WHITE),
}

local RARITY_LIST = objects.Array()

for _,r in pairs(lp.rarities) do
    RARITY_LIST:add(r)
end
RARITY_LIST:sortInPlace(function(a, b)
    return a.rarityWeight > b.rarityWeight
end)

---@type lootplot.rarities.Rarity[] | objects.Array
lp.rarities.RARITY_LIST = RARITY_LIST


---Availability: Client and Server
---@param r1 lootplot.rarities.Rarity
---@return number rarity weight of the rarity object. Lower means more rare.
function lp.rarities.getWeight(r1)
    return r1.rarityWeight
end


if server then

---Availability: **Server**
---@param ent Entity
---@param rarity lootplot.rarities.Rarity
function lp.rarities.setEntityRarity(ent, rarity)
    ent.rarity = rarity
    sync.syncComponent(ent, "rarity")
end

end


local shiftTc = typecheck.assert("table", "number")


---Availability: Client and Server
---@param rarity lootplot.rarities.Rarity
---@param delta number
---@return lootplot.rarities.Rarity
function lp.rarities.shiftRarity(rarity, delta)
    shiftTc(rarity, delta)
    if rarity.rarityWeight == 0 or rarity == lp.rarities.UNIQUE then
        -- cannot shift UNIQUE rarity. (That would be weird)
        return rarity
    end
    for i,r in ipairs(RARITY_LIST) do
        if r.rarityWeight == rarity.rarityWeight then
            local choice = math.clamp(i + delta, 1, #RARITY_LIST)
            return RARITY_LIST[choice]
        end
    end
    -- FAILED!
    umg.log.error("What the sigma??? This code should nevr run...")
    return rarity
end



local function dummy()
    return 1
end



do
---@type {[string]: generation.Generator}
local genCache = {}

local function createItemGenerator(rarity)
    return lp.newItemGenerator({
        filter = function(etypeName, _)
            local etype = server.entities[etypeName]
            if etype and etype.rarity and etype.rarity.id == rarity.id then
                ---@cast etype table
                return lp.metaprogression.isEntityTypeUnlocked(etype)
            end
            return false
        end
    })
end


---Availability: Client and Server
---@param rarity lootplot.rarities.Rarity
---@param dynamicSpawnChance? generation.PickChanceFunction Function that returns the chance of an item being picked. 1 means pick always, 0 means fully skip this item (filtered out), anything inbetween is the chance of said entry be accepted or be rerolled.
---@return (fun(...): Entity)?
function lp.rarities.randomItemOfRarity(rarity, dynamicSpawnChance)
    local gen = genCache[rarity] or createItemGenerator(rarity)
    dynamicSpawnChance = dynamicSpawnChance or dummy
    ---@cast gen generation.Generator
    if gen:isEmpty() then
        return nil
    end
    local etypeName = gen:query(function(entry, weight)
        return dynamicSpawnChance(entry, weight) or 1
    end)
    return server.entities[etypeName]
end

end



do
---@type {[string]: generation.Generator}
local genCache = {}

local function createSlotGenerator(rarity)
    return lp.newSlotGenerator({
        filter = function(etypeName, _)
            local etype = server.entities[etypeName]
            if etype and etype.rarity and etype.rarity.id == rarity.id then
                ---@cast etype table
                return lp.metaprogression.isEntityTypeUnlocked(etype)
            end
            return false
        end
    })
end

---Availability: Client and Server
---@param rarity lootplot.rarities.Rarity
---@param dynamicSpawnChance? generation.PickChanceFunction Function that returns the chance of an item being picked. 1 means pick always, 0 means fully skip this item (filtered out), anything inbetween is the chance of said entry be accepted or be rerolled.
---@return (fun(...): Entity)?
function lp.rarities.randomSlotOfRarity(rarity, dynamicSpawnChance)
    local gen = genCache[rarity] or createSlotGenerator(rarity)
    dynamicSpawnChance = dynamicSpawnChance or dummy
    ---@cast gen generation.Generator
    local etypeName = gen:query(function(entry, weight)
        return dynamicSpawnChance(entry, weight) or 1
    end)
    return server.entities[etypeName]
end

end

