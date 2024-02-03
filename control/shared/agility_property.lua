


--[[

Agility determines how "responsive" an entity's movement is.
It's a number between 0 and 1.

1 = change velocity instantly
0 = cannot change velocity

-1 = entity will move in opposite direction! lol!

For example, a charging bull has LOW agility. (= 0.2)
But a hummingbird has HIGH agility, (= 0.95)





]]


properties.defineProperty("agility", {
    base = "baseAgility",
    default = 0.6,
    shouldComputeClientside = true,

    getModifier = function(ent)
        return umg.ask("control:getAgilityModifier", ent) or 0
    end,
    getMultiplier = function(ent)
        return umg.ask("control:getAgilityMultiplier", ent) or 1
    end
})

