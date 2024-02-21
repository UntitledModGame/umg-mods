
--[[

uiInteractConfig component:
uiInteractConfig component does a few things:
    Gives `authorizeInRange` component to entity
    Gives `clickToOpenUI` to entity


ent.uiInteractConfig = {
    openSound = "open_chest",
    closeSound = "close_chest"
}

]]


-- this value seems "reasonable"
local DEFAULT_INTERACT_DISTANCE = 400


local function getInteractionDist(ent)
    return ent.uiInteractConfig.distance or DEFAULT_INTERACT_DISTANCE
end


components.project("uiInteractConfig", "clickToOpenUI", function(ent)
    local clickToOpenUI = {
        distance = getInteractionDist(ent)
    }
    return clickToOpenUI
end)



components.project("uiInteractConfig", "authorizeInRange", function(ent)
    local distance = getInteractionDist(ent)
    local authorizeInRange = {
        --[[
            the reason we have a bit of a large auth distance,
            is because we don't want players to be kicked out of the UI
            if they are pushed just a tiny bit out of bounds.
            That would be terrible UX!
        ]]
        distance = distance * 1.3
    }
    return authorizeInRange
end)


