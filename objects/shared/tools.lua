

local objects = {}


function objects.assertKeys(tabl, keys)
    --[[
        asserts that `tabl` is a table, 
        and that it has all of the keys listed in the `keys` table.
    ]]
    if type(tabl) ~= "table" then
        error("Expected table, got: " .. type(tabl), 2)
    end
    for _, key in ipairs(keys) do
        if tabl[key] == nil then
            error("Missing key: " .. tostring(key), 2)
        end
    end
end


function objects.injectKeys(tabl, keyTable)
    for k,v in pairs(keyTable) do
        tabl[k] = v
    end
end


function objects.inlineMethods(self)
    --[[
        inline all methods in an object for efficiency,
        such that there is no __index overhead.
        (Just copies over key-vals)
    ]]
    local mt = getmetatable(self)
    for k,v in pairs(mt.__index) do
        self[k] = v
    end
end


return objects