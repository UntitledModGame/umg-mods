if false then utf8 = require("utf8") end -- sumneko hack

---@class text.Text: objects.Class
local Text = objects.Class("text:Text")

local defaultEffectGroup = require("client.defaultEffectGroup")
local Character = require("client.Character")

---@param text string
---@param args text.TextArgs?
function Text:init(text, args)
    args = args or {}

    ---@type {call:boolean,effects:{inst:any,update:fun(self:any,subtext:text.Character[])}[],text:string?,evaltext:string?,subtexts:text.Character[]}[]
    self.evals = {}
    self.variables = args.variables or _G
    self.effectGroup = args.effectGroup or defaultEffectGroup
    self.font = args.font or love.graphics.getFont()

    self.fontHeight = self.font:getHeight()
    self.lines = 1

    self:_parse(text)
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

---@param text string
---@private
function Text:_parse(text)
    ---@type string[]
    local tempchar = {} -- This keep all the raw characters.
    local activeEffects = {} -- This keep the list of effect instances.
    ---@type string[]
    local activeEffectNames = {} -- This keep the list of effect names. The indices matches the activeEffects table.

    local function flushTempChar()
        local result = table.concat(tempchar)
        table.clear(tempchar)
        return result
    end

    local function flush(hasInterp, interpCall)
        local concatText = flushTempChar()
        if #concatText == 0 then
            return
        end

        local interpText, evalText
        if hasInterp then
            interpText = concatText
        else
            evalText = concatText
        end

        self.evals[#self.evals+1] = {
            effects = activeEffects,
            text = interpText,
            evaltext = evalText,
            call = interpCall,
            subtexts = {}
        }
        table.clear(tempchar)
        activeEffects = table.shallowCopy(activeEffects)
    end

    local hasInterp = false
    local interpCall = false
    local interpCallConfirmed = false
    local maybeBracket = false
    local maybeClosingBracket = false
    local openingBracket = false
    local endOfEffect = false
    local effectName = nil
    local effectKey = nil
    local i = 1 -- Character position index, in UTF-8 text
    local effectArgs = {}
    self.lines = 1

    table.clear(self.evals)

    for _, c in utf8.codes(text) do
        local char = utf8.char(c)

        if openingBracket then
            if hasInterp then
                -- Currently in string interpolation
                if interpCall then
                    if char == ")" then
                        interpCallConfirmed = true
                    else
                        umg.melt(string.format("col %d: expected \")\" but got %q when specifying interpolation call modifier", i, char))
                    end
                elseif #tempchar == 0 then
                    if not isValidVariableCharacter(c, true) then
                        umg.melt(string.format("col %d: invalid character %q when specifying variable name", i, char))
                    end

                    tempchar[#tempchar+1] = char
                elseif char == "(" then
                    if #tempchar == 0 then
                        umg.melt(string.format("col %d: invalid character %q when expecting variable name", i, char))
                    end

                    interpCall = true
                elseif char == "}" then
                    if #tempchar == 0 then
                        umg.melt(string.format("col %d: invalid character %q when expecting variable name", i, char))
                    end

                    -- End of string interpolation
                    if interpCall and not interpCallConfirmed then
                        umg.melt(string.format("col %d: expected \")\" but got \"}\" when specifying interpolation call modifier", i))
                    end

                    flush(hasInterp, interpCall)
                    hasInterp = false
                    interpCall = false
                    interpCallConfirmed = false
                    openingBracket = false
                elseif isValidVariableCharacter(c, false) then
                    tempchar[#tempchar+1] = char
                else
                    umg.melt(string.format("col %d: invalid identifier character %q when specifying interpolation identifier", i, char))
                end
            elseif endOfEffect then
                -- Currently specifying end of effect name
                if char == "}" then
                    -- Load end of effect
                    -- Case: {/effect}
                    --               ^ = i
                    local found = false
                    local ename = flushTempChar()

                    for j = #activeEffectNames, 1, -1 do
                        if activeEffectNames[j] == ename then
                            -- Remove the effect out
                            table.remove(activeEffects, j)
                            table.remove(activeEffectNames, j)
                            found = true
                            break
                        end
                    end

                    if not found then
                        umg.melt(string.format("col %d: found no opening %q effect tag", i - #ename, ename))
                    end

                    endOfEffect = false
                    openingBracket = false
                elseif isValidVariableCharacter(c, #tempchar == 0) then
                    -- Case: {/effect}
                    --         ^^^^^^ = i
                    tempchar[#tempchar+1] = char
                else
                    umg.melt(string.format("col %d: invalid identifier character %q when specifying effect name", i, char))
                end
            -- The rest of this must be specifying effect right now
            elseif char == "}" then
                -- End of effect
                if effectKey then
                    -- End of specifying effect value
                    -- Case: {effect key=value}
                    --                        ^ = i
                    if #tempchar == 0 then
                        umg.melt(string.format("col %d: effect value is empty", i - 1))
                    end

                    local effectValueStr = flushTempChar()
                    local effectValue = tonumber(effectValueStr)
                    if effectValue == nil then
                        umg.melt(string.format("col %d: effect value %q cannot be converted to number", i - #effectValue, effectValue))
                    end

                    effectArgs[effectKey] = effectValue
                elseif effectName then
                    -- Incomplete effect key
                    umg.melt(string.format("col %d: effect key is incomplete", i))
                else
                    effectName = flushTempChar()
                end

                -- Make effect
                local effectFunc = self.effectGroup:getEffectInfo(effectName)
                if not effectFunc then
                    umg.melt(string.format("col %d: effect %q does not exist", i - #effectName, effectName))
                end

                activeEffects[#activeEffects+1] = {
                    inst = effectArgs,
                    update = effectFunc
                }
                activeEffectNames[#activeEffectNames+1] = effectName
                effectArgs = {} -- Note: cannot use table.clear here
                effectName = nil
                effectKey = nil
                openingBracket = false
            elseif char == " " then
                -- Indicate starting new effect parameter
                if not effectName then
                    effectName = flushTempChar()
                elseif effectKey then
                    -- TODO: Deduplicate
                    if #tempchar == 0 then
                        umg.melt(string.format("col %d: effect value is empty", i - 1))
                    end

                    local effectValueStr = flushTempChar()
                    local effectValue = tonumber(effectValueStr)
                    if effectValue == nil then
                        umg.melt(string.format("col %d: effect value %q cannot be converted to number", i - #effectValue, effectValue))
                    end

                    effectArgs[effectKey] = effectValue
                    effectKey = nil
                end
                -- Don't error because we need to allow as many spaces
            elseif char == "=" and effectName then
                effectKey = flushTempChar()
                -- Case: {effect key=value}
                --                  ^ = i
            elseif isValidVariableCharacter(c, #tempchar == 0) or effectKey then
                -- Either specifying effect name, effect key, or effect value
                -- Case: {effect key=value}
                --        ^^^^^^ ^^^ ^^^^^ = i
                tempchar[#tempchar+1] = char
            else
                if effectName then
                    umg.melt(string.format("col %d: invalid character %q when specifying effect key", i, char))
                else
                    umg.melt(string.format("col %d: invalid character %q when specifying effect name", i, char))
                end
            end
        elseif maybeBracket then
            -- Previous character is opening bracket
            if char == "{" then
                -- Escape the tag
                -- Case: {{effect}}
                --       ?^ = i
                tempchar[#tempchar+1] = "{"
                maybeBracket = false
            else
                flush(hasInterp, interpCall)
                openingBracket = true

                if char == "$" then
                    -- String interpolation
                    hasInterp = true
                elseif char == "/" then
                    -- End of an effect
                    endOfEffect = true
                elseif isValidVariableCharacter(c, true) then
                    -- New effect
                    tempchar[#tempchar+1] = char
                else
                    umg.melt(string.format("col %d: invalid character %q when specifying effect name", i, char))
                end

                maybeBracket = false
            end
        elseif maybeClosingBracket then
            if char == "}" then
                -- Case: {{effect}}
                --               ?^ = i
                tempchar[#tempchar+1] = "}"
                maybeClosingBracket = false
            else
                umg.melt(string.format("col %d: unexpected character %q while parsing", i, char))
            end
        elseif char == "{" then
            maybeBracket = true
        elseif char == "}" then
            maybeClosingBracket = true
        elseif isCharDrawable(c) then
            tempchar[#tempchar+1] = char
        end

        i = i + 1
    end

    flush(hasInterp, interpCall)

    if #activeEffectNames > 0 then
        umg.melt(string.format("col %d: unclosed effect %q", i, activeEffectNames[#activeEffectNames]))
    end
end

---@param eval {call:boolean,effects:{inst:any,update:fun(self:any,subtext:text.Character?,dt:number)}[],text:string?,evaltext:string?,subtexts:text.Character[]}
---@param start integer
---@return integer
---@private
function Text:_updateSubtext(eval, start)
    local i = 0
    for _, c in utf8.codes(eval.evaltext) do
        i = i + 1
        local char = utf8.char(c)
        local subtext

        if eval.subtexts[i] then
            subtext = eval.subtexts[i]
            -- This is quite hacky of calling :init() directly.
            subtext:init(self.font, char, start)
        else
            subtext = Character(self.font, char, start)
            eval.subtexts[#eval.subtexts+1] = subtext
        end

        start = start + 1
    end

    return start
end

---@generic T
---@param t T[]
---@param i integer?
---@return (fun(table: T[], i?: integer):integer, T), T, integer?
local function iterArraysWithOffset(t, i)
    -- This is hacky way to tell ipairs to start AFTER specific index.
    return ipairs(table), t, i
end

---This (re)build the subtexts.
---@private
function Text:_rebuildAllSubtextsOfEvals()
    local start = 1

    for _, eval in ipairs(self.evals) do
        if eval.text then
            -- Evaluate string interpolator
            local interpData
            if eval.call then
                interpData = tostring(self.variables[eval.text]())
            else
                interpData = tostring(self.variables[eval.text])
            end

            if interpData ~= eval.evaltext then
                eval.evaltext = interpData
                start = self:_updateSubtext(eval, start)
            end
        elseif #eval.subtexts == 0 then
            -- Only update subtext once
            start = self:_updateSubtext(eval, start)
        else
            start = start + #eval.subtexts
        end
    end
end

---This reset the previous effect subtext values.
---@private
function Text:_resetSubtextEffects()
    for _, eval in ipairs(self.evals) do
        for i = 1, #eval.evaltext do
            eval.subtexts[i]:reset()
        end
    end
end

---Apply effects to the characters.
---@private
function Text:_applyEffects()
    -- Stage 3: Update subtext effects
    ---@type text.Character[]
    local toEvaluate = {}
    for i, eval in ipairs(self.evals) do
        for _, effect in ipairs(eval.effects) do
            -- Copy current subtexts
            for _, st in ipairs(eval.subtexts) do
                toEvaluate[#toEvaluate+1] = st
            end

            -- Get next evals until no more intersection
            for _, e in iterArraysWithOffset(self.evals, i) do
                local hasEffect = false
                for _, ef in ipairs(e.effects) do
                    if ef == effect then
                        hasEffect = true
                        break
                    end
                end

                if hasEffect then
                    -- Copy the subtexts
                    for _, st in ipairs(e.subtexts) do
                        toEvaluate[#toEvaluate+1] = st
                    end
                else
                    -- Stop here, this effect no longer affect this (and subsequent) eval.
                    break
                end
            end

            effect.update(effect.inst, toEvaluate)
            table.clear(toEvaluate)
        end
    end
end

---@param subtexts text.Character[]
---@param x number
---@param y number
---@private
function Text:_makeSubtextPositionAbsolute(subtexts, x, y)
    for _, subtext in ipairs(subtexts) do
        local tx, ty = subtext:getPosition()
        subtext:setPosition(x + tx, y + ty)

        -- Apply pre-effects
        self:effectCharacter(subtext)
    end
end

---This computes the text placement.
---@param maxwidth number
---@private
function Text:_computeTextPositions(maxwidth)
    ---@type text.Character[]
    local sentence = {}
    local sentenceWidth = 0
    ---@type text.Character?
    local lastSubtext = nil
    local line = 0
    local lineWidth = 0
    local hasDrawnCurrentLine = false
    local lastIsWhitespace = false

    for _, eval in ipairs(self.evals) do
        for i = 1, (eval.evaltext and #eval.evaltext or 0) do
            local subtext = eval.subtexts[i]
            local char = subtext:getChar()
            local width = subtext:getDimensions()
            local kerning = 0

            if lastSubtext then
                kerning = self.font:getKerning(lastSubtext:getChar(), subtext:getChar())
            end

            if char == "\n" then
                -- Flush current sentences
                self:_makeSubtextPositionAbsolute(sentence, lineWidth, line * self.fontHeight)
                table.clear(sentence)

                -- Move it to next line
                line = line + 1
                lineWidth = 0
                kerning = 0
                sentenceWidth = 0
                hasDrawnCurrentLine = false
                lastIsWhitespace = false
            elseif char == " " or char == "\t" then
                lastIsWhitespace = true
            elseif lastIsWhitespace then
                -- Flush current sentence
                self:_makeSubtextPositionAbsolute(sentence, lineWidth, line * self.fontHeight)
                table.clear(sentence)
                lineWidth = lineWidth + sentenceWidth
                sentenceWidth = 0
                hasDrawnCurrentLine = true
                lastIsWhitespace = false
                lastSubtext = nil
            elseif (lineWidth + sentenceWidth + width + kerning) >= maxwidth then
                if (not hasDrawnCurrentLine) or lastIsWhitespace then
                    -- The whole sentence does not fit.
                    self:_makeSubtextPositionAbsolute(sentence, lineWidth, line * self.fontHeight)
                    table.clear(sentence)
                    sentenceWidth = 0
                end

                -- Move it to next line
                line = line + 1
                lineWidth = 0
                kerning = 0
                hasDrawnCurrentLine = false
                lastIsWhitespace = false
                lastSubtext = nil
            else
                lastIsWhitespace = false
            end

            local subx, suby = subtext:getPosition()
            subtext:setPosition(subx + sentenceWidth, suby)
            sentenceWidth = sentenceWidth + width + kerning
            sentence[#sentence+1] = subtext
        end
    end

    -- Update last sentence
    self:_makeSubtextPositionAbsolute(sentence, lineWidth, line * self.fontHeight)
end

---Draw the rich text effect.
---@param x number
---@param y number
---@param rot number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
---@param kx number?
---@param ky number?
---@private
function Text:_draw(x, y, rot, sx, sy, ox, oy, kx, ky)
    love.graphics.push("all")
    love.graphics.applyTransform(x, y, rot, sx, sy, ox, oy, kx, ky)

    local r, g, b, a = love.graphics.getColor()

    for _, eval in ipairs(self.evals) do
        for _, subtext in ipairs(eval.subtexts) do
            subtext:draw(r, g, b, a)
        end
    end

    love.graphics.pop()
end

---@param obj any
---@param t string
---@return boolean
local function isLOVEType(obj, t)
    return type(obj) == "userdata" and obj.typeOf and obj:typeOf(t)
end

---Draw the rich text effect.
---@param transform love.Transform
---@param maxwidth number? Maximum width the text can occupy before breaking sentence to next line.
---@diagnostic disable-next-line: duplicate-set-field
function Text:draw(transform, maxwidth) end

---Draw the rich text effect.
---@param x number
---@param y number
---@param maxwidth number? Maximum width the text can occupy before breaking sentence to next line.
---@param r number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
---@param kx number?
---@param ky number?
---@diagnostic disable-next-line: duplicate-set-field
function Text:draw(x, y, maxwidth, r, sx, sy, ox, oy, kx, ky)
    if isLOVEType(x, "Transform") then
        maxwidth = y
    end

    self:_rebuildAllSubtextsOfEvals()
    self:_resetSubtextEffects()
    self:_computeTextPositions(maxwidth or math.huge)
    self:_applyEffects()
    self:_draw(x, y, r, sx, sy, ox, oy, kx, ky)
end

---Called on every characters that will be drawn on screen.
---
---Can be overridden by user
---@param char text.Character
function Text:effectCharacter(char)
end

---Retrieve the font object used to create this rich text
---@return love.Font
function Text:getFont()
    return self.font
end

---Retrieve the unformatted string of this rich text effect.
---@return string string The plain text (without effect tags and with string interpolation value evaluated) in this string
function Text:getString()
    self:_rebuildAllSubtextsOfEvals()
    local result = {}

    for _, eval in ipairs(self.evals) do
        result[#result+1] = eval.evaltext
    end

    return table.concat(result)
end
Text.__tostring = Text.getString

---Retrieve the list of texts in this Text object without all the effect text.
---@param maxwidth number
---@return number maxwidth Maximum width that the text occupy.
---@return string[] strings List of lines.
function Text:getWrap(maxwidth)
    local text = self:getString()
    return self.font:getWrap(text, maxwidth)
end

if false then
    ---@param text string
    ---@param args text.TextArgs?
    ---@return text.Text
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function Text(text, args) end
end

return Text
