local love = require("love")
local utf8 = require("utf8")

---@class text.Text: objects.Class
local Text = objects.Class("text:Text")

local defaultEffectGroup = require("client.defaultEffectGroup")
local SubText = require("client.SubText")

---@param text string
---@param args text.TextArgs?
function Text:init(text, args)
    args = args or {}

    ---@type {call:boolean,effects:{inst:any,update:fun(self:any,subtext:text.SubText?,dt:number)}[],text:string?,evaltext:string?,subtexts:text.SubText[]}[]
    self.evals = {}
    self.variables = args.variables or _G
    self.effectGroup = args.effectGroup or defaultEffectGroup
    self.font = args.font or love.graphics.getFont()
    self.maxWidth = args.maxWidth or math.huge

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
    ---@type text.Effect[]
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
                        umg.melt(string.format("col %d: found no matching %q effect tag", i - #ename, ename))
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
                local effectInfo = self.effectGroup:getEffectInfo(effectName)
                if not effectInfo then
                    umg.melt(string.format("col %d: effect %q does not exist", i - #effectName, effectName))
                end

                activeEffects[#activeEffects+1] = {
                    inst = effectInfo.maker(effectArgs),
                    update = effectInfo.update
                }
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
            elseif isValidVariableCharacter(c, #tempchar == 0) then
                -- Either specifying effect name or effect key
                -- Case: {effect key=value}
                --        ^^^^^^ ^^^ = i
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

---@param eval {call:boolean,effects:{inst:any,update:fun(self:any,subtext:text.SubText?,dt:number)}[],text:string?,evaltext:string?,subtexts:text.SubText[]}
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
            subtext:init(char, start, self.font:getWidth(char), self.fontHeight)
        else
            subtext = SubText(char, start, self.font:getWidth(char), self.fontHeight)
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

---Update the rich text effect.
---@param dt number Time elapsed since last frame, in seconds.
function Text:update(dt)
    local start = 1

    -- Stage 1: (Re)build subtexts.
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

    -- Stage 2: Reset subtext effects
    for _, eval in ipairs(self.evals) do
        for i = 1, #eval.evaltext do
            eval.subtexts[i]:reset()
        end
    end

    -- Stage 3: Update subtext effects
    ---@type text.SubText[]
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
                    -- Stop here, this effect no longer affect this eval.
                    break
                end
            end

            effect.update(effect.inst, toEvaluate, dt)
            table.clear(toEvaluate)
        end
    end

    -- TODO: Should we update text positions in here?
end

---@param subtexts text.SubText[]
---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
---@param a number
function Text:_drawSubtexts(subtexts, x, y, r, g, b, a)
    for _, subtext in ipairs(subtexts) do
        local c1, c2, c3, c4 = subtext:getColor():getRGBA()
        local tx, ty = subtext:getPosition()
        local angle = subtext:getRotation()
        local sx, sy = subtext:getScale()
        local ox, oy = subtext:getOffset()
        local kx, ky = subtext:getShear()
        love.graphics.setColor(r * c1, g * c2, b * c3, a * c4)
        love.graphics.print(
            subtext:getChar(),
            self.font,
            x + tx, y + ty, angle,
            sx, sy, ox, oy, kx, ky
        )
    end
end

---Draw the rich text effect.
---@param x number
---@param y number
---@param r number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
---@param kx number?
---@param ky number?
---@overload fun(self:text.Text,transform:love.Transform)
function Text:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    love.graphics.push("all")
    love.graphics.applyTransform(x, y, r, sx, sy, ox, oy, kx, ky)

    local currentColor = objects.Color(love.graphics.getColor())
    ---@type text.SubText[]
    local sentence = {}
    local sentenceWidth = 0
    ---@type text.SubText?
    local lastSubtext = nil
    local line = 0
    local lineWidth = 0
    local hasDrawnCurrentLine = false

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
                -- Flush
                self:_drawSubtexts(sentence, lineWidth, line * self.fontHeight, currentColor:getRGBA())
                table.clear(sentence)

                -- Move it to next line
                line = line + 1
                lineWidth = 0
                kerning = 0
                sentenceWidth = 0
                hasDrawnCurrentLine = false
            end

            if char == " " or char == "\t" then
                -- Flush
                self:_drawSubtexts(sentence, lineWidth, line * self.fontHeight, currentColor:getRGBA())
                table.clear(sentence)
                lineWidth = lineWidth + sentenceWidth
                sentenceWidth = 0
                hasDrawnCurrentLine = true
            elseif (lineWidth + sentenceWidth + width + kerning) >= self.maxWidth then
                if not hasDrawnCurrentLine then
                    -- Edge case: The whole sentence does not fit. Draw right now.
                    self:_drawSubtexts(sentence, lineWidth, line * self.fontHeight, currentColor:getRGBA())
                    table.clear(sentence)
                end

                -- Move it to next line
                line = line + 1
                lineWidth = 0
                kerning = 0
                hasDrawnCurrentLine = false
            end

            sentenceWidth = sentenceWidth + width + kerning
        end
    end

    -- Draw last sentence
    self:_drawSubtexts(sentence, lineWidth, line * self.fontHeight, currentColor:getRGBA())

    love.graphics.pop()
end

if false then
    ---@param text string
    ---@param args text.TextArgs?
    ---@return text.Text
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function Text(text, args) end
end

return Text
