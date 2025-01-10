
local interp = localization.newInterpolator



text.defineEffect("lootplot.targets:COLOR", function(args, char)
    char:setColor(lp.targets.TARGET_COLOR)
end)



local TRIGGER_ORDER = 10
local TRIGGER_TXT = interp("Activates On: {lootplot:LISTEN_COLOR}{wavy}Target item %{trigger}")
umg.on("lootplot:populateDescription", TRIGGER_ORDER, function(ent, arr)
    if ent.listen and ent.shape then
        local triggerName = lp.getTriggerDisplayName(ent.listen.trigger)
        local targetText = TRIGGER_TXT({
            trigger = triggerName
        })
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

