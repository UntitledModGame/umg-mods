


local effects = {}



local function addEffect(ent, effectEnt)
    if not ent.effects then
        ent.effects = objects.Set()
    end
    if ent.effects:has(effectEnt) then
        return -- already has effect
    end
    ent.effects:add(effectEnt)
    umg.call("effects:effectAdded", effectEnt, ent)
end



local function removeEffect(ent, effectEnt)
    if not ent.effects then
        return -- no effects
    end
    if not ent.effects:has(effectEnt) then
        return -- doesnt have effect in question
    end

    ent.effects:remove(effectEnt)
    umg.call("effects:effectRemoved", effectEnt, ent)

    --[[
    I've commented this VVVVV out because its quite fragile due to
    effectHandler components projecting to `effect`.
    if ent.effects:size() <= 0 then
        ent:removeComponent("effects")
    end
    ]]
end




if server then
--[[
    server-only API:
]]

function effects.addEffect(ent, effectEnt)
    addEffect(ent, effectEnt)
    if server then
        server.broadcast("effects.addEffect", ent, effectEnt)
    end
end


function effects.removeEffect(ent, effectEnt)
    removeEffect(ent, effectEnt)
    if server then
        server.broadcast("effects.removeEffect", ent, effectEnt)
    end
end

end




if client then
    client.on("effects.addEffect", addEffect)
    client.on("effects.removeEffect", removeEffect)
end





local effectsGroup = umg.group("effects")


umg.on("@tick", function()
    for _, ent in ipairs(effectsGroup) do
        for _, effectEnt in ipairs(ent.effects) do
            if (not umg.exists(effectEnt)) then
                -- remove effect if the entity doesn't exist anymore
                removeEffect(ent, effectEnt)
            end
        end
    end
end)


return effects

