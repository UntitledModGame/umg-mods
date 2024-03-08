

local usage = require("shared.usage")


local controllableGroup = umg.group("inventory", "controllable", "clickToUseHoldItem")


local listener = input.InputListener({priority = 2})


local function useItems()
    local used = false
    for _, ent in ipairs(controllableGroup) do
        if sync.isClientControlling(ent) then
            local wasUsed = usage.useHoldItem(ent)
            used = used or wasUsed
        end
    end
    return used
end



listener:onPressed("input:CLICK_PRIMARY", function(self, controlEnum)
    local used = useItems()
    if used then
        -- only lock if an item was actually used
        self:claim(controlEnum)
    end
end)
