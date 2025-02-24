local loc = localization.localize

local glassBreakSound

if client then
    local source = love.audio.newSource("entities/slots/sounds/glass_break_04.wav", "static")
    audio.defineAudio("lootplot.s0:glass_break_04", source)
    audio.tag("lootplot.s0:glass_break_04", "audio:sfx")
    glassBreakSound = sound.Sound("lootplot.s0:glass_break_04", 0.4)
end

return lp.defineSlot("lootplot.s0:glass_slot", {
    image = "glass_slot",
    name = loc("Glass slot"),
    description = loc("Has a 10% chance of being destroyed when activated"),
    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(ent)
        local item = lp.slotToItem(ent)
        if item and item.doomCount then
            -- dont destroy self when holding a DOOMED item.
            -- It's really annoying when this happens lmao,
            -- I try to expand my plot with a dragonfruit, and the glass-slot breaks!

            -- so im hardcoding it to NOT happen >:)
            return
        end

        if lp.SEED:randomMisc() < 0.1 then
            -- WELP! riparoni pepperoni
            lp.destroy(ent)
        end
    end,

    onDestroyClient = function(ent)
        glassBreakSound:play(ent)
    end
})

