if false then utf8 = require("utf8") end -- sumneko hack

local Character = require("client.Character")
local defaultEffectGroup = require("client.defaultEffectGroup")

---@param fmt string
local function stopErr(fmt, ...)
    local txt = string.format(fmt, ...)
    love.graphics.pop()

    -- TODO: Debug check
    umg.melt(txt, 2)
    return false, txt
end

local characterCache = {}

---@param font love.Font
---@param character string
---@param start integer
---@return text.Character
local function pollCharacterCache(font, character, start)
    if #characterCache == 0 then
        return Character(font, character, start)
    else
        local char = table.remove(characterCache)
        char:init(font, character, start)
        char:reset()
        return char
    end
end

---@param c text.Character
local function storeCharacterCache(c)
    characterCache[#characterCache+1] = c
end

local drawState = {
    ---@type {[1]:text.Character,[2]:{name:string,args:table,func:fun(args:table,character:text.Character)}[]}[]
    currentWord = {},
    textLineX = 0,
    currentWordWidth = 0,
    lastSubtext = nil,
    hasDrawnCurrentLine = false,
    lastIsWhitespace = false,
    currentLine = 1,
}

local function resetDrawState()
    table.clear(drawState.currentWord)
    drawState.textLineX = 0
    drawState.currentWordWidth = 0
    drawState.lastSubtext = nil
    drawState.hasDrawnCurrentLine = false
    drawState.lastIsWhitespace = false
    drawState.currentLine = 1
end

---@param x number
---@param y number
local function flushCurrentWords(x, y)
    for _, charInfo in ipairs(drawState.currentWord) do
        local tx, ty = charInfo[1]:getPosition()
        charInfo[1]:setPosition(x + tx, y + ty)

        for _, eff in ipairs(charInfo[2]) do
            eff.func(eff.args, charInfo[1])
        end

        storeCharacterCache(charInfo[1])
    end

    table.clear(drawState.currentWord)
end

---@param font love.Font
---@param maxWidth number
---@param fontHeight number
---@param index integer
---@param character string
---@param effects {name:string,args:table,func:fun(args:table,character:text.Character)}[]
local function drawSingle(font, maxWidth, fontHeight, index, character, effects)
    local subtext = pollCharacterCache(font, character, index)
    local char = subtext:getChar()
    local width = subtext:getDimensions()
    local kerning = 0

    if drawState.lastSubtext then
        kerning = font:getKerning(drawState.lastSubtext:getChar(), subtext:getChar())
    end

    if char == "\n" then
        -- Flush current sentences
        flushCurrentWords(drawState.textLineX, drawState.currentLine * fontHeight)

        -- Move it to next line
        drawState.textLineX = 0
        drawState.currentLine = drawState.currentLine + 1
        kerning = 0
        drawState.currentWordWidth = 0
        drawState.hasDrawnCurrentLine = false
        drawState.lastIsWhitespace = false
    elseif char == " " or char == "\t" then
        drawState.lastIsWhitespace = true
    elseif drawState.lastIsWhitespace then
        -- Flush current sentence
        flushCurrentWords(drawState.textLineX, drawState.currentLine * fontHeight)

        drawState.textLineX = drawState.textLineX + drawState.currentWordWidth
        drawState.currentWordWidth = 0
        drawState.hasDrawnCurrentLine = true
        drawState.lastIsWhitespace = false
        drawState.lastSubtext = nil
    elseif (drawState.textLineX + drawState.currentWordWidth + width + kerning) > maxWidth then
        if (not drawState.hasDrawnCurrentLine) or drawState.lastIsWhitespace then
            -- The whole word does not fit.
            flushCurrentWords(drawState.textLineX, drawState.currentLine * fontHeight)
            drawState.currentWordWidth = 0
        end

        -- Move it to next line
        drawState.currentLine = drawState.currentLine + 1
        drawState.textLineX = 0
        kerning = 0
        drawState.hasDrawnCurrentLine = false
        drawState.lastIsWhitespace = false
        drawState.lastSubtext = nil
    else
        drawState.lastIsWhitespace = false
    end

    local subx, suby = subtext:getPosition()
    subtext:setPosition(subx + drawState.currentWordWidth, suby)
    drawState.currentWordWidth = drawState.currentWordWidth + width + kerning
    drawState.currentWord[#drawState.currentWord+1] = {subtext, table.shallowCopy(effects)}
    drawState.lastSubtext = subtext
end

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

---@param obj any
---@param t string
---@return boolean
local function isLOVEType(obj, t)
    return type(obj) == "userdata" and obj.typeOf and obj:typeOf(t)
end

---Draw rich text directly without state.
---@param txt string Formatted rich text
---@param eg text.EffectGroup|nil Effect group
---@param limit number
---@param transform love.Transform
---@return boolean,(string|nil)
---@diagnostic disable-next-line: missing-return
local function drawRichText(txt, eg, limit, transform) end

---Draw rich text directly without state.
---@param txt string Formatted rich text
---@param eg text.EffectGroup|nil Effect group
---@param x number
---@param y number
---@param limit number
---@param rot number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
---@param kx number?
---@param ky number?
function drawRichText(txt, eg, x, y, limit, rot, sx, sy, ox, oy, kx, ky)
    if isLOVEType(y, "Transform") then
        limit = x
        x = y
    end

    eg = eg or defaultEffectGroup
    local font = love.graphics.getFont()

    love.graphics.push("all")
    love.graphics.applyTransform(x, y, rot, sx, sy, ox, oy, kx, ky)
    resetDrawState()

    local fontHeight = font:getHeight()
    local maybeOpeningBracket = false
    local maybeClosingBracket = false
    local openingBracket = false
    local endOfEffect = false
    local effectName = nil
    local effectKey = nil
    local i = 1 -- Character position index when parsing, in UTF-8 text
    local j = 1 -- Character position index when drawing, in UTF-8 text
    local buffer = {}
    local effects = {} ---@type {name:string,args:table,func:fun(args:table,character:text.Character)}[]

    for _, c in utf8.codes(txt) do
        local char = utf8.char(c)

        if openingBracket then
            if endOfEffect then
                -- Currently specifying end of effect name
                if char == "}" then
                    -- Load end of effect
                    -- Case: {/effect}
                    --               ^ = i
                    local found = false
                    local ename = concatAndClean(buffer)

                    for j = #effects, 1, -1 do
                        if effects[j].name == ename then
                            -- Remove the effect out
                            table.remove(effects, j)
                            found = true
                            break
                        end
                    end

                    if not found then
                        return stopErr("col %d: found no opening %q effect tag", i - #ename, ename)
                    end

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
                -- End of effect
                if effectKey then
                    -- End of specifying effect value
                    -- Case: {effect key=value}
                    --                        ^ = i
                    if #buffer == 0 then
                        return stopErr("col %d: effect value is empty", i - 1)
                    end

                    local effectValueStr = concatAndClean(buffer)
                    local effectValue = tonumber(effectValueStr)
                    if effectValue == nil then
                        return stopErr("col %d: effect value %q cannot be converted to number", i - #effectValue, effectValue)
                    end

                    effects[#effects].args[effectKey] = effectValue
                elseif effectName then
                    -- Incomplete effect key
                    return stopErr("col %d: effect key is incomplete", i)
                else
                    effectName = concatAndClean(buffer)
                end

                -- Make effect
                local effectFunc = eg:getEffectInfo(effectName)
                if not effectFunc then
                    return stopErr("col %d: effect %q does not exist", i - #effectName, effectName)
                end

                effects[#effects+1] = {
                    name = effectName,
                    args = {},
                    func = effectFunc,
                }
                effectName = nil
                effectKey = nil
                openingBracket = false
            elseif char == " " then
                -- Indicate starting new effect parameter
                if not effectName then
                    effectName = concatAndClean(buffer)
                elseif effectKey then
                    -- TODO: Deduplicate
                    if #buffer == 0 then
                        return stopErr("col %d: effect value is empty", i - 1)
                    end

                    local effectValueStr = concatAndClean(buffer)
                    local effectValue = tonumber(effectValueStr)
                    if effectValue == nil then
                        return stopErr("col %d: effect value %q cannot be converted to number", i - #effectValue, effectValue)
                    end

                    effects[#effects].args[effectKey] = effectValue
                    effectKey = nil
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
                drawSingle(font, fontHeight, limit, j, char, effects)
                j = j + 1
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
                drawSingle(font, fontHeight, limit, j, char, effects)
                j = j + 1
                maybeClosingBracket = false
            else
                return stopErr("col %d: unexpected character %q while parsing", i, char)
            end
        elseif char == "{" then
            maybeOpeningBracket = true
        elseif char == "}" then
            maybeClosingBracket = true
        elseif isCharDrawable(c) then
            drawSingle(font, fontHeight, limit, j, char, effects)
            j = j + 1
        end

        i = i + 1
    end

    if #effects > 0 then
        local names = {}
        for _, e in ipairs(effects) do
            names[#names+1] = e.name
        end

        return stopErr("col %d: unclosed effect: %s", i, table.concat(names, ", "))
    end

    love.graphics.pop()
    return true
end

return drawRichText