


local projectionMap = {--[[
    [component] -> List<{
        component = component,
        value = value
    }>
]]}



local function set(etype, comp, value)
    if type(value) == "function" then
        value = value(etype, comp)
        assert(value, "Projected component value cannot be nil")
    end
    etype[comp] = value
end


local function tryProject(etype, srcComponent)
    local projections = projectionMap[srcComponent]
    if not projections then return end

    for _, pObj in ipairs(projections) do
        local comp, val = pObj.component, pObj.value
        if not etype[comp] then
            set(etype, comp, val)
            -- Since we have just created a new component, `comp`,
            -- we need to check if this new component `comp` projects to anything.
            -- (If we didn't allow this, then transistive-projections wouldn't work.)
            -- (For example, project(A,B), project(B,C)   )
            tryProject(etype, comp)
        end
    end
end



umg.on("@newEntityType", function(etype, _etypename)
    local buffer = objects.Array()
    for comp, _ in pairs(etype) do
        -- buffer, so we don't modify etype during pairs loop
        buffer:add(comp)
    end

    for _, comp in ipairs(buffer) do
        tryProject(etype, comp)
    end
end)




local projectSharedTc = typecheck.assert("string", "string")
local function defineSharedProjection(srcComp, targetComp, value)
    projectSharedTc(srcComp, targetComp)
    if not projectionMap[srcComp] then
        projectionMap[srcComp] = objects.Array()
    end

    projectionMap[srcComp]:add({
        component = targetComp,
        value = value or true
    })
end


return defineSharedProjection

