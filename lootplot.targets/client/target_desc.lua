
local loc = localization.localize



text.defineEffect("lp_targetColor", function(args, char)
    char:setColor(lp.targets.TARGET_COLOR)
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
    SLOT = "{lp_targetColor}Targets slots:",
    ITEM = "{lp_targetColor}Targets items:",
    NO_SLOT = "{lp_targetColor}Targets empty spaces:",
    NO_ITEM = "{lp_targetColor}Targets empty slots:",
}
local TARGET_TYPE_TEXT_FALLBACK = "{lp_targetColor}Targets unknown:"

umg.on("lootplot:populateDescription", TARGET_SHAPE_ORDER, function(ent, arr)
    if ent.targetShape then
        local targetText = TARGET_TYPE_TEXT[ent.targetType] or TARGET_TYPE_TEXT_FALLBACK
        arr:add(loc(targetText,nil,BRIEF_CTX))
    end
end)



umg.on("lootplot:populateDescription", TARGET_FILTER_ORDER, function(ent, arr)
    if ent.targetShape and ent.targetTrait then
        arr:add(loc("{lp_targetColor}If target has %{trait} trait: ", {
            trait = lp.getTraitDisplayName(ent.targetTrait)
        }, BRIEF_CTX))
    end
end)





umg.on("lootplot:populateDescription", TARGET_ACTIVATE_ORDER, function(ent, arr)
    if ent.targetShape and ent.targetActivationDescription then
        local typ = type(ent.targetActivationDescription)
        if typ == "string" then
            -- should already be localized:
            arr:add("{lp_targetColor}" .. ent.targetActivationDescription)
        elseif typ == "function" then
            arr:add(function()
                -- need to pass ent manually as a closure
                if umg.exists(ent) then
                    return ent.targetActivationDescription(ent)
                end
            end)
        end
    end
end)


local MISC_ORDER = 50

umg.on("lootplot:populateDescription", MISC_ORDER, function(ent, arr)
    if ent.targetShape then
        -- should already be localized:
        arr:add(loc("Shape: {wavy}{lp_targetColor}%{shapeName}", {
            shapeName = ent.targetShape.name
        }))
    end
end)

