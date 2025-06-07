---@param text string
---@param vars table<string, any>
local function interpolate(text, vars)
    ---@param str string
    local interpolated = text:gsub("(%%+{[^}]+})", function(str)
        local percentages = 0

        for i = 1, #str do
            if str:sub(i, i) == "%" then
                percentages = percentages + 1
            else
                break
            end
        end

        assert(percentages > 0)
        local result = str:sub(percentages + 1)
        if percentages % 2 == 1 then
            -- We're interpolating
            local variableData = str:sub(percentages + 2, -2)
            local variable, format = variableData:match("([^:]+):?(.*)")

            local value = vars[variable]
            if #format > 0 then
                local ok
                ok, result = pcall(string.format, "%"..format, value)
                if not ok then
                    umg.melt("Error attempting to interpolate: " .. text)
                end
            elseif value == nil then
                --[[
                the reason we do this is to signal to other systems 
                that the {} should be ignored.
                (In UMG, double {{ implies an ESCAPED bracket sequence.)
                ]]
                result = "%{{"..variable.."}}"
            else
                result = tostring(value)
            end
        end

        return string.rep("%", percentages / 2)..result
    end)
    return interpolated
end

return interpolate
