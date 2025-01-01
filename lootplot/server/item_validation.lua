

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


local function isInvalid(itemEnt, ppos)
    if not ppos then
        -- if we dont have a `ppos`, then we have ZERO
        -- information about the item. So just leave it be.
        return false
    end

    return not lp.couldContainItem(ppos, itemEnt)
end


umg.on("@tick", scheduling.skip(3, function()
    local time = love.timer.getTime()
    for _, itemEnt in ipairs(itemGroup)do
        local ppos = lp.getPos(itemEnt)
        if isInvalid(itemEnt, ppos) then
            -- welp, start timeout!
            timeouts[itemEnt] = timeouts[itemEnt] or time
        else
            -- reset.
            timeouts[itemEnt] = nil
        end

        if timeouts[itemEnt] and time > (timeouts[itemEnt] + TIMEOUT) then
            lp.destroy(itemEnt)
        end
    end
end))

