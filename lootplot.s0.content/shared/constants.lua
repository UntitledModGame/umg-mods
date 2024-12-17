

local constants = {
    NULL_ITEM = "manure",

    DEFAULT_GRUB_MONEY_CAP = 10,

    GOLDSMITH_MONEY_REQUIREMENT = 30,

    -- item tags:
    tags = setmetatable({
        TREASURE = "lootplot.s0.content:treasure",
        FOOD = "lootplot.s0.content:food"
    }, {__index=umg.melt})
}

for _,tagId in pairs(constants.tags) do
    lp.defineTag(tagId)
end


return constants

