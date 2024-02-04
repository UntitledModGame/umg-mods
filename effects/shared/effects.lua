




local effects = {}


local function canRemoveEffect(ent, effectEnt)
    if not ent.effects then
        return -- no effects
    end
    if not ent.effects:has(effectEnt) then
        return -- doesnt have effect in question
    end

    local isBlocked = umg.ask("effects:isEffectRemovalBlocked", effectEnt, ent)
    return not isBlocked
end


local function canAddEffect(ent, effectEnt)
    if ent.effects and ent.effects:has(effectEnt) then
        return false -- already has effect!
    end

    -- IMPORTANT NOTE:
    -- ent is NOT guaranteed to have `effects` component at this
    --   point in time!
    local isBlocked = umg.ask("effects:isEffectAdditionBlocked", effectEnt, ent)
    return not isBlocked
end



local function addEffect(ent, effectEnt)
    if not canAddEffect(ent, effectEnt) then
        return -- can't add!
    end

    if not ent.effects then
        ent.effects = objects.Set()
    end
    ent.effects:add(effectEnt)
    umg.call("effects:effectAdded", effectEnt, ent)
end



local function removeEffect(ent, effectEnt)
    if not canRemoveEffect(ent, effectEnt) then
        return -- can't remove!
    end

    ent.effects:remove(effectEnt)
    umg.call("effects:effectRemoved", effectEnt, ent)
    --[[
    -- I've commented this VVVVV out because its quite fragile due to
    --   effectHandler components projecting to `effect`.
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
        server.broadcast("effects:addEffect", ent, effectEnt)
    end
end


function effects.removeEffect(ent, effectEnt)
    removeEffect(ent, effectEnt)
    if server then
        server.broadcast("effects:removeEffect", ent, effectEnt)
    end
end

end


effects.canAddEffect = canAddEffect
effects.canRemoveEffect = canRemoveEffect



if client then
    client.on("effects:addEffect", addEffect)
    client.on("effects:removeEffect", removeEffect)
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

