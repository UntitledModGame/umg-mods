

local effects = {}


if server then
--[[
    server-only API:
]]

function effects.addEffect(ent, effectEnt)
    if not ent.effects then
        ent.effects = objects.Set()
    end
    if ent.effects:has(effectEnt) then
        return -- already has effect
    end
    ent.effects:add(effectEnt)
    umg.call("effects:effectAdded", effectEnt, ent)

    if server then
        server.broadcast("effects.addEffect", ent, effectEnt)
    end
end


function effects.removeEffect(ent, effectEnt)
    if not ent.effects then
        return -- no effects
    end
    if not ent.effects:has(effectEnt) then
        return -- doesnt have effect in question
    end

    ent.effects:remove(effectEnt)
    umg.call("effects:effectRemoved", effectEnt, ent)
    if ent.effects:size() <= 0 then
        ent:removeComponent("effects")
    end
    
    if server then
        server.broadcast("effects.removeEffect", ent, effectEnt)
    end
end

end


if client then
    client.on("effects.addEffect", function(ent, effectEnt)
        effects.addEffect(ent, effectEnt)
    end)

    client.on("effects.removeEffect", function(ent, effectEnt)
        effects.removeEffect(ent, effectEnt)
    end)
end





return effects

