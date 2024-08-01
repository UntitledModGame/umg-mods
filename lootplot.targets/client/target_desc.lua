
local loc = localization.localize

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


umg.on("lootplot:populateDescription", TARGET_SHAPE_ORDER, function(ent, arr)
    if ent.targetShape then
        arr:add(loc("{c r=1 g=0.55 b=0.1}For all targets: ",nil,BRIEF_CTX))
    end
end)



umg.on("lootplot:populateDescription", TARGET_FILTER_ORDER, function(ent, arr)
    if ent.targetShape and ent.targetTrait then
        arr:add(loc("{c r=1 g=0.55 b=0.1}  If target has %{trait} trait: ", {
            trait = lp.getTraitDisplayName(ent.targetTrait)
        }, BRIEF_CTX))
    end
end)





umg.on("lootplot:populateDescription", TARGET_ACTIVATE_ORDER, function(ent, arr)
    if ent.targetShape and ent.targetActivationDescription then
        local typ = type(ent.targetActivationDescription)
        if typ == "string" then
            -- should already be localized:
            arr:add("{c r=1 g=0.55 b=0.1}" .. ent.targetActivationDescription)
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
        arr:add(loc("Shape: {wavy}{c r=1 g=0.55 b=0.1}%{shapeName}", {
            shapeName = ent.targetShape.name
        }))
    end
end)

