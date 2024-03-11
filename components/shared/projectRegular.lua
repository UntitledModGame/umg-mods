


--[[
This data structure is used during component removal.
When a projecting comp is removed, 
we need to check if the target is still viable.

For example:
ent.image = "monkey"
    ent.drawable --> true
ent.shadow = {...}
    ent.drawable --> true
ent:removeComponent("image")
    ent.drawable --> should still be true!
]]
local targetToProjectorGroupSet = {--[[
    Maps targetComponents to the projectors.

    [targComp] -> List{ group1, group2, group3, ... }
    A list of groups that are used for projection onto targComp.
]]}


local type = type


local function setupProjection(group, targComp, targetValue)
    if type(targetValue) == "function" then
        local func = targetValue
        group:onAdded(function(ent)
            if not ent[targComp] then
                ent[targComp] = func(ent, targComp)
            end
        end)
    else
        group:onAdded(function(ent)
            if not ent[targComp] then
                ent[targComp] = targetValue
            end
        end)
    end
end




local function setupProjectionRemoval(group, targComp)
    group:onRemoved(function(ent)
        --[[
            This is kinda bad, since it makes entity deletion
            O(n^2), where `n` is the number of rcomps being projected to our targComp.

            I think its fine tho.
        ]]
        if not ent[targComp] then
            return -- wtf??? okay...? How tf did this happen?!??
        end

        if ent:isSharedComponent(targComp) then
            return -- we can't remove shcomps
        end

        local projectorGroupList = targetToProjectorGroupSet[targComp]
        for _, pGroup in ipairs(projectorGroupList) do
            if pGroup:has(ent) then
                -- We shouldn't remove the targComp,
                -- since there is another group that is projecting it.
                return
            end
        end

        -- okay, remove the targComp:
        ent:removeComponent(targComp)
    end)
end




local function getGroup(comp_or_group)
    if type(comp_or_group) == "string" then
        return umg.group(comp_or_group)
    elseif type(comp_or_group) == "table" then
        return comp_or_group
    end
end




--[[
    projects a component onto another component.

    For example:
    `components.project("image", "drawable", true)`
    
    This is basically saying:
    when an entity gets an `image` component:
        set `ent.drawable = true`
    
    We can also do groups:
    local g = umg.group("foo", "bar")
    components.project(g, "foobar")

]]
local projectTc = typecheck.assert("string|table", "string")
local function project(projection, targComp, targetValue)
    --[[
        `projection` is either a component that is being projected,
        or a group who's members will be projected.

        `targComp` is the component that will be created.

        `targetValue` is either a component value,
            or a function that generates a component value.
    ]]
    projectTc(projection, targComp)
    targetValue = targetValue or true

    local group = getGroup(projection)

    -- add group to projector group list:
    local set = targetToProjectorGroupSet[targComp]
    if not set then
        set = objects.Set()
        targetToProjectorGroupSet[targComp] = set
    end
    set:add(group)

    -- set up group projection addition/removal:
    setupProjection(group, targComp, targetValue)
    setupProjectionRemoval(group, targComp)
end


return project
