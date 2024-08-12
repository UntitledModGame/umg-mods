

--[[

floating-item system

(handles deletion of items that dont have a slot.)

]]


local TIMEOUT = 1 -- after this amount of time;
-- if an item STILL does not have a slot, then we will delete it.



local timeouts = setmetatable({--[[
    [itemEnt] -> timeWithoutSlot
]]}, {__mode="k"})


local itemGroup = umg.group("item")



umg.on("@tick", scheduling.skip(3, function()
    local time = umg.getWorldTime()
    for _, ent in ipairs(itemGroup)do
        local ppos = lp.getPos(ent)
        local isOverSlot = ppos and (not lp.posToSlot(ppos))

        if isOverSlot and (not lp.canItemFloat(ent)) then
            -- welp, start timeout!
            timeouts[ent] = timeouts[ent] or time
        else
            -- reset.
            timeouts[ent] = nil
        end
    end

    for itemEnt, t in pairs(timeouts) do
        if t + TIMEOUT > time then
            if umg.exists(itemEnt) then
                lp.destroy(itemEnt)
            end
        end
    end
end))

