
local loc = localization.localize
local interp = localization.newInterpolator



text.defineEffect("lootplot.targets:COLOR", function(args, char)
    char:setColor(lp.targets.TARGET_COLOR)
end)
text.defineEffect("lootplot.targets:LISTEN_COLOR", function(args, char)
    char:setColor(lp.targets.LISTEN_COLOR)
end)



--[[

ORDER = 10 trigger
ORDER = 20 filter
ORDER = 30 action

ORDER = 50 misc
ORDER = 60 important misc

]]

-- we want to be rendered as part of the action;
-- And we want target-stuff rendered together;
-- hence the 32.* range.
local TARGET_SHAPE_ORDER = 32.4
local TARGET_FILTER_ORDER = 32.5
local TARGET_ACTIVATE_ORDER = 32.6

local BRIEF_CTX = {
    context = "Keep it brief, concise, and straightforward!"
}

local TARGET_TYPE_TEXT = {
    SLOT = loc("{lootplot.targets:COLOR}Targets slots:", nil, BRIEF_CTX),
    ITEM = loc("{lootplot.targets:COLOR}Targets items:", nil, BRIEF_CTX),
    NO_SLOT = loc("{lootplot.targets:COLOR}Targets spaces without slots:", nil, BRIEF_CTX),
    NO_ITEM = loc("{lootplot.targets:COLOR}Targets spaces without items:", nil, BRIEF_CTX),
    SLOT_NO_ITEM = loc("{lootplot.targets:COLOR}Targets empty slots:", nil, BRIEF_CTX),
    ITEM_OR_SLOT = loc("{lootplot.targets:COLOR}Targets items and slots:", nil, BRIEF_CTX),
}
local TARGET_TYPE_TEXT_FALLBACK = loc("{lootplot.targets:COLOR}Targets unknown:", nil, BRIEF_CTX)

umg.on("lootplot:populateDescription", TARGET_SHAPE_ORDER, function(ent, arr)
    if ent.target and ent.shape and ent.target.description then
        local targetText = TARGET_TYPE_TEXT[ent.target.type] or TARGET_TYPE_TEXT_FALLBACK
        arr:add(targetText)
    end
end)





local TRIGGER_ORDER = 10
local TRIGGER_TXT = interp("Trigger: {lootplot.targets:LISTEN_COLOR}{wavy}When target item %{trigger}")

umg.on("lootplot:populateDescription", TRIGGER_ORDER, function(ent, arr)
    if ent.listen and ent.shape then
        local triggerName = lp.getTriggerDisplayName(ent.listen.trigger)
        local targetText = TRIGGER_TXT({
            trigger = triggerName
        })
        arr:add(targetText)
    end
end)




local function addTargDescription(arr, ent, desc, colorEffect)
    local typ = type(desc)
    if typ == "string" then
        -- should already be localized:
        arr:add(colorEffect .. desc)
    elseif objects.isCallable(desc) then
        arr:add(function()
            -- need to pass ent manually as a closure
            if umg.exists(ent) then
                return colorEffect .. desc(ent)
            end
        end)
    end
end

umg.on("lootplot:populateDescription", TARGET_ACTIVATE_ORDER, function(ent, arr)
    if ent.target and ent.target.description then
        addTargDescription(arr, ent, ent.target.description, "{lootplot.targets:COLOR}" )
    end
    if ent.listen and ent.listen.description then
        addTargDescription(arr, ent, ent.listen.description, "{lootplot.targets:LISTEN_COLOR}" )
    end
end)



local MISC_ORDER = 50
local SHAPE = interp("Shape: {wavy}{lootplot.targets:COLOR}%{name}")

umg.on("lootplot:populateDescription", MISC_ORDER, function(ent, arr)
    if ent.shape then
        -- should already be localized:
        arr:add(SHAPE(ent.shape))
    end
end)

