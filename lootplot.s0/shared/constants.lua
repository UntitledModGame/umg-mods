

local constants = {
    NULL_ITEM = "manure",

    DEFAULT_GRUB_MONEY_CAP = 10,

    STARTING_MONEY = 10,
    STARTING_POINTS = 0,
    ROUNDS_PER_LEVEL = 6,
    MONEY_PER_ROUND = 8,

    GOLDSMITH_MONEY_REQUIREMENT = 20,

    -- item tags:
    tags = setmetatable({
        TREASURE = "lootplot.s0:treasure",
        FOOD = "lootplot.s0:food"
    }, {__index=umg.melt})
}

for _,tagId in pairs(constants.tags) do
    lp.defineTag(tagId)
end


return constants

