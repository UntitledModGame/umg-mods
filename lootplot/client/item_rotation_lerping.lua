

local itemGroup = umg.group("item", "lootplotRotation")


itemGroup:onAdded(function(ent)
    ent.rot = lp.getItemRotation(ent) * (math.pi/2)
end)



local INTERPOLATION_RATE = 0.25 -- higher number = faster.
-- (1 = instant)
assert(INTERPOLATION_RATE < 1, "Wot")


local EPSILON = 0.0001


local function dif(a,b)
    return math.abs(a-b)
end

umg.on("@update", function(dt)
    for _, ent in ipairs(itemGroup) do
        local currRot = ent.rot or 0
        local targRot = lp.getItemRotation(ent) * (math.pi/2)

        if dif(currRot, targRot) > EPSILON then
            -- then we need to change value
            if currRot > targRot then
                -- then we add a full rotation to targRot,
                -- Because we only rotate in one direction!
                targRot = targRot + math.pi*2
            end

            -- recalculate diff, since we modified targRot
            local diff = dif(currRot, targRot)
            local delta = diff * INTERPOLATION_RATE
            ent.rot = (currRot + delta) % (math.pi*2)
        end
    end
end)


