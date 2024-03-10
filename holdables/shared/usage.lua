
--[[


Handles usage of items.



TODO:
All of this needs to be redone, to account for exotic use types.


]]

local usage = {}




local common = require("shared.common")

local getHoldItem = common.getHoldItem



local DEFAULT_ITEM_COOLDOWN = 0.2





function usage.canUseHoldItem(holder_ent, item)
    if (not umg.exists(holder_ent)) or (not umg.exists(item)) then
        return false
    end

    -- Else, we assume that any held item is usable.
    local time = state.getGameTime()
    local time_since_use = time - (item.itemLastUseTime or 0)
    local cooldown = (item.itemCooldown or DEFAULT_ITEM_COOLDOWN)
    if math.abs(time_since_use) < cooldown then
        return false
    end

    local usageBlocked = umg.ask("holdables:itemUsageBlocked", holder_ent, item)
    if usageBlocked then
        return false
    end

    if item.canUseItem ~= nil then
        if type(item.canUseItem) == "function" then
            return item:canUseItem(holder_ent) -- return callback value
        else
            return item.canUseItem -- it's a boolean
        end
    end

    return true
    -- assume that it can be used.
end




local function useItemDeny(item, holder_ent)
    if type(item.useItemDeny) == "function" then
        item:useItemDeny(holder_ent)
    end
    umg.call("holdables:useItemDeny", holder_ent, item)
end









if server then


local asserterDirect = typecheck.assert("entity?", "entity")
local function useItemDirectly(holder_ent, item)
    asserterDirect(holder_ent, item)
    -- holder_ent could be nil here
    if type(item.useItem) == "function" then
        item:useItem(holder_ent or false)
    end
    umg.call("holdables:useItem", holder_ent, item)
    server.broadcast("holdables:useSpecificItem", holder_ent, item)
    item.itemLastUseTime = state.getGameTime()
end


function usage.useHoldItem(holder_ent)
    local item = getHoldItem(holder_ent)
    if item then
        if usage.canUseHoldItem(holder_ent, item) then
            useItemDirectly(holder_ent, item)
        else
            useItemDeny(item, holder_ent)
        end
    end
end



server.on("holdables:useItem", function(sender, holder_ent)
    if not getHoldItem(holder_ent) then return end
    if holder_ent.controller ~= sender then return end

    usage.useHoldItem(holder_ent)
end)

end











if client then

local function canUse(holder_ent, item)
    return sync.isClientControlling(holder_ent)
        and usage.canUseHoldItem(holder_ent, item)
end

local asserter = typecheck.assert("entity")

function usage.useHoldItem(holder_ent)
    asserter(holder_ent)
    local item = getHoldItem(holder_ent)
    if canUse(holder_ent, item) then
        asserter(holder_ent)
        client.send("holdables:useItem", holder_ent)
        umg.call("holdables:useItem", holder_ent, item)
        if type(item.useItem) == "function" then
            item:useItem(holder_ent or false)
        end
        item.itemLastUseTime = state.getGameTime()
        return true
    elseif item then
        useItemDeny(item, holder_ent)
    end
end

umg.on("holdables:useItem", function(holder_ent, item)
    if holder_ent and sync.isClientControlling(holder_ent) then
        return -- ignore; we have already called `useItem`, 
        -- since we are the ones who sent the event!
    end
    item:useItem(holder_ent)
    item.itemLastUseTime = state.getGameTime()
end)

end



return usage

