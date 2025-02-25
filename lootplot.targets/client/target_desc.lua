
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
local TRIGGER_TXT = interp("Activates On: {lootplot:LISTEN_COLOR}{wavy}Target item %{trigger}")

umg.on("lootplot:populateDescription", TRIGGER_ORDER, function(ent, arr)
    if ent.listen and ent.shape then
        local listen = ent.listen
        local triggerName = lp.getTriggerDisplayName(ent.listen.trigger)

        local listenType = listen.type
        local listenTrigger = listen.trigger

        local targetText

        local t = HARDCODED_LISTEN_DESCRIPTIONS[listenType]
        if t and t[listenTrigger] then
            targetText = t[listenTrigger]
        else
            targetText = TRIGGER_TXT({
                trigger = triggerName
            })
        end
        arr:add(targetText)
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

