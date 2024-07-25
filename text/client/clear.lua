---@param char integer
local function isValidVariableCharacter(char, excludenum)
    if excludenum then
        return char == 95 or (char >= 65 and char <= 90) or (char >= 97 and char <= 122)
    else
        return (char >= 48 and char <= 57) or isValidVariableCharacter(char, true)
    end
end

local function isCharDrawable(char)
    return (char >= 32 and char ~= 127) or char == 0xa or char == 9
end

---@param t string[]
local function concatAndClean(t)
    local result = table.concat(t)
    table.clear(t)
    return result
end

---@param fmt string
local function stopErr(fmt, ...)
    local txt = string.format(fmt, ...)
    love.graphics.pop()

    -- TODO: Debug check
    return nil, txt
end

---Clear tags on rich text.
---@param txt string
local function clear(txt)
    local maybeOpeningBracket = false
    local maybeClosingBracket = false
    local openingBracket = false
    local endOfEffect = false
    local effectName = nil
    local effectKey = nil
    local i = 1 -- Character position index when parsing, in UTF-8 text
    local buffer = {}
    local textBuffer = {}

    for _, c in utf8.codes(txt) do
        local char = utf8.char(c)

        if openingBracket then
            if endOfEffect then
                -- Currently specifying end of effect name
                if char == "}" then
                    -- Load end of effect
                    -- Case: {/effect}
                    --               ^ = i
                    concatAndClean(buffer)
                    endOfEffect = false
                    openingBracket = false
                elseif isValidVariableCharacter(c, #buffer == 0) then
                    -- Case: {/effect}
                    --         ^^^^^^ = i
                    buffer[#buffer+1] = char
                else
                    return stopErr("col %d: invalid identifier character %q when specifying effect name", i, char)
                end
            -- The rest of this must be specifying effect right now
            elseif char == "}" then
                -- End of effect define
                if effectKey then
                    -- End of specifying effect value
                    -- Case: {effect key=value}
                    --                        ^ = i
                    if #buffer == 0 then
                        return stopErr("col %d: effect value is empty", i - 1)
                    end

                    concatAndClean(buffer)
                elseif effectName then
                    -- Incomplete effect key
                    return stopErr("col %d: effect key is incomplete", i)
                end

                effectName = nil
                effectKey = nil
                openingBracket = false
            elseif char == " " then
                -- Indicate starting new effect parameter
                if not effectName then
                    -- Make effect
                    effectName = concatAndClean(buffer)
                elseif effectKey then
                    -- TODO: Deduplicate
                    if #buffer == 0 then
                        return stopErr("col %d: effect value is empty", i - 1)
                    end

                    concatAndClean(buffer)
                end
                -- Don't error because we need to allow as many spaces
            elseif char == "=" and effectName then
                effectKey = concatAndClean(buffer)
                -- Case: {effect key=value}
                --                  ^ = i
            elseif isValidVariableCharacter(c, #buffer == 0) or effectKey then
                -- Either specifying effect name, effect key, or effect value
                -- Case: {effect key=value}
                --        ^^^^^^ ^^^ ^^^^^ = i
                buffer[#buffer+1] = char
            else
                if effectName then
                    return stopErr("col %d: invalid character %q when specifying effect key", i, char)
                else
                    return stopErr("col %d: invalid character %q when specifying effect name", i, char)
                end
            end
        elseif maybeOpeningBracket then
            -- Previous character is opening bracket
            if char == "{" then
                -- Escape the tag
                -- Case: {{effect}}
                --       ?^ = i
                textBuffer[#textBuffer+1] = char
                maybeOpeningBracket = false
            else
                openingBracket = true

                if char == "/" then
                    -- End of an effect
                    endOfEffect = true
                elseif isValidVariableCharacter(c, true) then
                    -- New effect
                    buffer[#buffer+1] = char
                else
                    return stopErr("col %d: invalid character %q when specifying effect name", i, char)
                end

                maybeOpeningBracket = false
            end
        elseif maybeClosingBracket then
            if char == "}" then
                -- Case: {{effect}}
                --               ?^ = i
                textBuffer[#textBuffer+1] = char
                maybeClosingBracket = false
            else
                return stopErr("col %d: unexpected character %q while parsing", i, char)
            end
        elseif char == "{" then
            maybeOpeningBracket = true
        elseif char == "}" then
            maybeClosingBracket = true
        elseif isCharDrawable(c) then
            textBuffer[#textBuffer+1] = char
        end

        i = i + 1
    end

    return table.concat(textBuffer)
end

return clear
