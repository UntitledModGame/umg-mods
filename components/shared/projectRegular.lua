


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
local targetToProjectors = {--[[
    Maps targetComponents to the projectors.

    [targComp] -> List{ view1, view2, view3, ... }
    A list of views that are used for projection onto targComp.
]]}


local type = type


local function setupProjection(view, targComp, targetValue)
    if type(targetValue) == "function" then
        local func = targetValue
        view:onAdded(function(ent)
            if not ent[targComp] then
                ent[targComp] = func(ent, targComp)
                assert(ent[targComp], "Projected component value cannot be nil")
            end
        end)
    else
        view:onAdded(function(ent)
            if not ent[targComp] then
                ent[targComp] = targetValue
            end
        end)
    end
end




local function setupProjectionRemoval(view, targComp)
    view:onRemoved(function(ent)
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

        local viewList = targetToProjectors[targComp]
        for _, pView in ipairs(viewList) do
            if pView:has(ent) then
                -- We shouldn't remove the targComp,
                -- since there is another view that is projecting it.
                return
            end
        end

        -- okay, remove the targComp:
        ent:removeComponent(targComp)
    end)
end




local function getView(comp_or_group)
    if type(comp_or_group) == "string" then
        return umg.view(comp_or_group)
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
        or a view/group who's members will be projected.

        `targComp` is the component that will be created.

        `targetValue` is either a component value,
            or a function that generates a component value.
    ]]
    projectTc(projection, targComp)
    targetValue = targetValue or true

    local view = getView(projection)

    -- add view/group to projector group list:
    local set = targetToProjectors[targComp]
    if not set then
        set = objects.Set()
        targetToProjectors[targComp] = set
    end
    set:add(view)

    -- set up projection addition/removal:
    setupProjection(view, targComp, targetValue)
    setupProjectionRemoval(view, targComp)
end


return project
