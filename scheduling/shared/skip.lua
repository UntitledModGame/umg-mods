
--[[

Returns a new function that only runs after being called X times.

Useful for running code every 5 frames, for example.

]]

local runEveryTc = typecheck.assert("number", "function")


local function skip(skips, func)
    --[[
        listens to a callback, but only runs it every `skips` runs.
    ]]
    runEveryTc(skips, func)

    local currentSkip = 0

    return function(...)
        currentSkip = currentSkip + 1

        if currentSkip >= skips then
            func(...)
            currentSkip = 0
        end
    end
end


return skip
