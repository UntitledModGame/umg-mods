
---@class lootplot.s0.CONSTANTS

---@type lootplot.s0.CONSTANTS
local constants = {
    NULL_ITEM = "manure",

    DEFAULT_GRUB_MONEY_CAP = 20,

    STARTING_MONEY = 10,
    STARTING_POINTS = 0,
    ROUNDS_PER_LEVEL = 6,

    ROUND_INCOME = {
        [0]= 8, -- easy = $8 per round
        [1] = 6, -- normal = $6
        [2] = 5 -- hard
    },

    UNLOCK_AFTER_WINS = {
        SKIP_LEVEL = 1, -- IMPORTANT NOTE: You cannot skip levels with one-ball!
        ROTATEY = 1, -- rotate-archetype is unlocked after 1 win
        REROLL = 1, -- ...
        GRUBBY = 2, -- grubby is unlocked after 2 wins
        -- etc etc
        DESTRUCTIVE = 3,
        SHARDS = 4,
        CONTRAPTIONS = 5,
        SHOPPY = 6,
    },

    CURSE_COUNT = 6,
    -- If there are more than X curses on the plot, 
    -- curses will begin to have adverse effects.

    GOLDSMITH_MONEY_REQUIREMENT = 20,

    -- entity tags:
    tags = setmetatable({
        -- item tags:
        TREASURE = "lootplot.s0:treasure",
        ROCKS = "lootplot.s0:rocks",
        DESTRUCTIVE = "lootplot.s0:destructive",
        FOOD = "lootplot.s0:food",
        CAT = "lootplot.s0:cat",
        CONTRAPTION = "lootplot.s0:contraption",

        -- item curse tags:
        INJUNCTION_CURSE = "lootplot.s0:injunction_curse",

        -- slot tags:
        GLASS_SLOT = "lootplot.s0:glass_slot",
        BASIC_SLOT = "lootplot.s0:basic_slot",
    }, {__index=umg.melt})
}

for _,tagId in pairs(constants.tags) do
    lp.defineTag(tagId)
end


return constants

