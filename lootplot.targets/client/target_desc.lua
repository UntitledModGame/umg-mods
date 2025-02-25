
local interp = localization.newInterpolator
local loc = localization.localize



text.defineEffect("lootplot.targets:COLOR", function(args, char)
    char:setColor(lp.targets.TARGET_COLOR)
end)



local HARDCODED_LISTEN_DESCRIPTIONS = {
    ITEM = {
        DESTROY = loc("When an item is Destroyed,"),
        PULSE = loc("When an item is {lootplot:TRIGGER_COLOR}Pulsed,"),
        BUY = loc("When an item is purchased,")
    },
    SLOT = {
        DESTROY = loc("When a slot is Destroyed,"),
        REROLL = loc("When a slot is {lootplot:TRIGGER_COLOR}Rerolled,"),
        PULSE = loc("When a slot is {lootplot:TRIGGER_COLOR}Pulsed,"),
    }
}


local TRIGGER_ORDER = 10
local TRIGGER_TXT_ITEM = interp("Activates On: {lootplot:LISTEN_COLOR}{wavy}Target item %{trigger}")
local TRIGGER_TXT_SLOT = interp("Activates On: {lootplot:LISTEN_COLOR}{wavy}Target slot %{trigger}")

umg.on("lootplot:populateDescription", TRIGGER_ORDER, function(ent, arr)
    if ent.listen and ent.shape then
        local listen = ent.listen
        local triggerName = lp.getTriggerDisplayName(ent.listen.trigger)

        local typ = listen.type
        local trigger = listen.trigger

        local targetText

        local t = HARDCODED_LISTEN_DESCRIPTIONS[typ]
        if t and t[trigger] then
            targetText = t[trigger]
        else
            if typ == "SLOT" then
                targetText = TRIGGER_TXT_SLOT({
                    trigger = triggerName
                })
            elseif typ == "ITEM" then
                targetText = TRIGGER_TXT_ITEM({
                    trigger = triggerName
                })
            else
                umg.log.fatal("Invalid listen type: " .. typ)
            end
        end
        if targetText then
            arr:add(targetText)
        end
    end
end)



local MISC_ORDER = 50
local SHAPE = interp("Target Shape: {wavy}{lootplot.targets:COLOR}%{name}")

umg.on("lootplot:populateDescription", MISC_ORDER, function(ent, arr)
    if ent.shape then
        -- should already be localized:
        arr:add(SHAPE(ent.shape))
    end
end)

