---@param text string
---@param vars table<string, any>
local function interpolate(text, vars)
    local maybeOpening = false
    local inVariableName = false
    local buffer = {}
    local result = {}

    -- Note: It doesn't matter if we're using UTF-8-aware or not.
    for i = 1, #text do
        local char = text:sub(i, i)

        if char == "%" then
            if maybeOpening then
                -- Escape
                maybeOpening = false
                result[#result+1] = "%"
            else
                maybeOpening = true
            end
        elseif char == "}" and inVariableName then
            local variableName = table.concat(buffer)
            local value = vars[variableName]
            table.clear(buffer)

            if value == nil then
                value = "%{{"..variableName.."}}"
            else
                value = tostring(value)
            end

            result[#result+1] = value
        elseif maybeOpening then
            if char == "{" then
                -- String interpolation opening tag confirmed
                inVariableName = true
            else
                -- Invalid
                result[#result+1] = "%"
                result[#result+1] = char
            end
            maybeOpening = false
        elseif inVariableName then
            buffer[#buffer+1] = char
        else
            result[#result+1] = char
        end
    end

    return table.concat(result)
end

return interpolate
