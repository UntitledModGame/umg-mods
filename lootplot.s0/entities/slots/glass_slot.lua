
local helper = require("shared.helper")
local constants = require("shared.constants")


local loc = localization.localize

local glassBreakSound

if client then
    local source = love.audio.newSource("entities/slots/sounds/glass_break_04.wav", "static")
    audio.defineAudio("lootplot.s0:glass_break_04", source, {"audio:sfx"})
    glassBreakSound = sound.Sound("lootplot.s0:glass_break_04", 0.4)
end



local function onActivate(ent)
    local item = lp.slotToItem(ent)
    if item and item.doomCount then
        -- dont destroy self when holding a DOOMED item.
        -- It's really annoying when this happens lmao,
        -- so im hardcoding it to NOT happen >:)
        return
    end

    if lp.SEED:randomMisc() < 0.1 then
        -- WELP! riparoni pepperoni
        lp.destroy(ent)
    end
end



local function defGlassSlot(id, etype)
    etype.onActivate = onActivate
    etype.lootplotTags = {constants.tags.GLASS_SLOT}
    etype.onDestroyClient = function(ent)
        glassBreakSound:play(ent)
    end

    lp.defineSlot(id, etype)
end




defGlassSlot("lootplot.s0:glass_slot", {
    image = "glass_slot",
    name = loc("Glass slot"),
    activateDescription = loc("Has a 10% chance of being destroyed"),
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,
})



defGlassSlot("lootplot.s0:glass_slot_money", {
    image = "glass_slot",
    name = loc("Glass slot"),
    activateDescription = loc("Has a 10% chance of being destroyed"),
    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    baseMoneyGenerated = 1,
})





do
local MULT = 3

defGlassSlot("lootplot.s0:red_glass_slot", {
    image = "red_glass_slot",
    name = loc("Red glass slot"),

    activateDescription = loc("Has a 10% chance of being destroyed"),
    description = loc("Items on this slot earn %{mult}x as much {lootplot:POINTS_MULT_COLOR}multiplier.{/lootplot:POINTS_MULT_COLOR}", {
        mult = MULT
    }),

    triggers = {"PULSE"},

    unlockAfterWins = 4,

    rarity = lp.rarities.EPIC,

    slotItemProperties = {
        multipliers = {
            multGenerated = MULT
        },
    },
})

end

