
--[[

basicUIEntity component:
basicUIEntity component does a few things:
    Gives `authorizeInRange` component to entity
    Gives `clickToOpenUI` component to entity
    Gives `toggleableUI` component to entity
    Gives `draggableUI` component to entity


ent.basicUIEntity = {
    -- todo; put other shit in here maybe
}

]]


-- this value seems "reasonable"
local DEFAULT_INTERACT_DISTANCE = 400


local function getInteractionDist(ent)
    local bui = ent.basicUIEntity
    if type(bui) == "table" then
        return bui.interactionDistance or DEFAULT_INTERACT_DISTANCE
    end
    return DEFAULT_INTERACT_DISTANCE
end



components.project("basicUIEntity", "clickToOpenUI", function(ent)
    local clickToOpenUI = {
        distance = getInteractionDist(ent)
    }
    return clickToOpenUI
end)



components.project("basicUIEntity", "draggableUI")

components.project("basicUIEntity", "toggleableUI")

components.project("basicUIEntity", "clampedUI")


components.project("basicUIEntity", "authorizeInRange", function(ent)
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

