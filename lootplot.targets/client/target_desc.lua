
local interp = localization.newInterpolator
local loc = localization.localize



text.defineEffect("lootplot.targets:COLOR", function(args, char)
    char:setColor(lp.targets.TARGET_COLOR)
end)



local HARDCODED_LISTEN_DESCRIPTIONS = {
    ITEM = {
        DESTROY = loc("When a target item is Destroyed,"),
        PULSE = loc("When a target item is {lootplot:TRIGGER_COLOR}Pulsed,"),
        BUY = loc("When a target item is purchased,"),
        BUFF = loc("When a target item is buffed,"),
    },
    SLOT = {
        DESTROY = loc("When a target slot is Destroyed,"),
        REROLL = loc("When a target slot is {lootplot:TRIGGER_COLOR}Rerolled,"),
        PULSE = loc("When a target slot is {lootplot:TRIGGER_COLOR}Pulsed,"),
    }
}


local TRIGGER_ORDER = 10

umg.on("lootplot:populateTriggerDescription", TRIGGER_ORDER, function(ent, arr)
    if ent.listen and ent.shape then
        local listen = ent.listen

        local typ = listen.type
        local trigger = listen.trigger

        local targetText

        local t = HARDCODED_LISTEN_DESCRIPTIONS[typ]
        if t and t[trigger] then
            targetText = t[trigger]
            arr:add(targetText)
        else
            umg.log.warn("Unknown listen-type; Unable to generate description: ", typ, trigger)
        end
    end
end)



local MISC_ORDER = 50

umg.on("lootplot:populateDescriptionTags", MISC_ORDER, function(ent, arr)
    if ent.shape then
        -- should already be localized:
        local txt = ("{wavy}{lootplot.targets:COLOR}%s{/wavy}{/lootplot.targets:COLOR}")
            :format(ent.shape.name)
        arr:add(txt)
    end
end)

