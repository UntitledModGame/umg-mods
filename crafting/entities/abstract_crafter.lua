

--[[
    TODO: A bunch of this needs to be refactored to fit
    with the new inventory ui API.
]]
local function craftOnClick(inv)
    assert(client, "this should only be called clientside")
    local ent = inv.owner
    if not umg.exists(ent) then
        return -- ???? I guess we can't craft...?
    end

    local itemX = ent.craftItemLocation[1]
    local itemY = ent.craftItemLocation[2]    
    ent.crafter:tryCraft(inv, itemX, itemY)
end



--[[
    abstract crafting entity.
]]
local abstractCrafter = {
    --[[
        TODO: all this is broken
    ]]

    super = function(ent)
        if (type(ent.crafter) ~= "table") or (not ent.crafter.executeCraft) then
            umg.melt("craftable entities must be given a .crafter member")
        end
    end
}


return abstractCrafter

