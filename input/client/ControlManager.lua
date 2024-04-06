
--[[

Big class that handles all controls, and control-locking.


]]


local ControlManager = objects.Class("input:ControlManager")



local FAMILIES = objects.Enum({
    -- list of valid input families:
    "mouse",
    "key",
    "scroll",
    --[[
        in future: controller stuff:

        axis family. Eg:
            axis:left
            axis:up
            axis:down
            axis:right
        gamepad family. Eg:
            gamepad:a
            gamepad:b
            gamepad:c
    ]]
})


local function checkKey(scancode)
    local key = love.keyboard.getKeyFromScancode(scancode)
    if key ~= "unknown" then
        return true
    end
end


local VALID_MOUSE_BUTTONS = objects.Enum({
    "1", "2", "3", "4", "5"
})
local function checkMouseButton(button)
    return VALID_MOUSE_BUTTONS:has(button)
end


local VALID_SCROLL_DIRECTIONS = objects.Enum({
    "left", "up", "down", "right"
})
local function checkScroll(scrollDir)
    return VALID_SCROLL_DIRECTIONS:has(scrollDir)
end





local function toPair(s)
    -- converts an inputKey (family:input)
    -- To a pair:  family, input
    local i = s:find("%:")
    return s:sub(1,i-1), s:sub(i+1)
end


local function fromPair(family, input)
    -- converts a pair to a `family:input`
    return family .. ":" .. tostring(input)
end


local function assertInputVal(bool, inputVal)
    if not bool then
        umg.melt("Invalid input val: " .. tostring(inputVal))
    end
end

local function assertValidInput(inputVal)
    local family, inp = toPair(inputVal)

    if family == FAMILIES.scroll then
        assertInputVal(checkScroll(inp), inputVal)
    elseif family == FAMILIES.key then
        assertInputVal(checkKey(inp), inputVal)
    elseif family == FAMILIES.mouse then
        assertInputVal(checkMouseButton(inp), inputVal)
    else
        umg.melt("Invalid input family: " .. tostring(inputVal))
    end
end




function ControlManager:init(args)
    typecheck.assertKeys(args, {
        "onControlPressed", "onControlReleased"
    })
    objects.inlineMethods(self)

    self.onControlPressed = args.onControlPressed
    self.onControlReleased = args.onControlReleased

    self.controlToInputs = {--[[
        [controlEnum] -> Set{
            "key:a", "mouse:1", ...
        }
    ]]}

    self.inputToControls = {--[[
        [family:input] -> Set{
            controlEnum1, controlEnum2, ...
        }
    ]]}

    self.controlLocks = {--[[
        [controlEnum] -> true
        Allows us to lock controls directly
    ]]}
    self.familyLocks = {--[[
        [family] -> true or false

        Allows us to lock input families
            (only persists for one frame tho.)
            (^^^ todo; this is kinda weird????)
    ]]}

    self.validControls = {--[[
        [controlEnum] -> true/false
    ]]}
end



local function clearControls(self)
    self:resetLocks()
    self.controlToInputs = {}
    self.inputToControls = {}
end




local defineNewControlTc = typecheck.assert("table", "string")

local function defineNewControl(self, controlEnum)
    defineNewControlTc(self, controlEnum)
    if self.validControls[controlEnum] then
        umg.melt("controlEnum was already defined: " .. controlEnum)
    end
    self.validControls[controlEnum] = true
    self.controlToInputs[controlEnum] = objects.Array()
end


function ControlManager:defineControls(controls)
    for _, cEnum in ipairs(controls) do
        defineNewControl(self, cEnum)
    end
end





local function setControl(self, controlEnum, inputValList)
    self.controlToInputs[controlEnum] = objects.Array(inputValList)

    for _, inputVal in ipairs(inputValList) do
        assertValidInput(inputVal)
        local inpToCont = self.inputToControls[inputVal] or objects.Array() 
        self.inputToControls[inputVal] = inpToCont
        inpToCont:add(controlEnum)
    end
end


function ControlManager:setControls(mapping)
    --[[
        mapping = {
            [CONTROL_ENUM] --> { inputVal1, inputVal2, ... }
        }
    ]]
    mapping = table.copy(mapping) -- defensive copy, since we mutate
    -- copy over old controls:
    for controlEnum, inputValList in pairs(self.controlToInputs) do
        mapping[controlEnum] = mapping[controlEnum] or inputValList
    end

    -- Clear controls:
    -- the reason we clear controls, is because there are a lot of gnarly
    -- 2-way mappings. Its a lot more robust if we just take the old controls, and do a full reset.
    clearControls(self)
    -- Then, set new controls:
    for controlEnum, inputValList in pairs(mapping) do
        assert(self.validControls[controlEnum], "Invalid control: " .. controlEnum)
        setControl(self, controlEnum, inputValList)
    end
end



function ControlManager:isValidControl(controlEnum)
    return self.validControls[controlEnum]
end




local isDownChecks = {
    key = function(x)
        return love.keyboard.isScancodeDown(x)
    end,
    mouse = function(x)
        return love.mouse.isDown(tonumber(x))
    end,
    scroll = function()
        -- not much we can do here.... 
        -- mousewheel movements are ephemeral and instantaneous
        return false
    end
}

for k,_v in pairs(FAMILIES) do
    if not isDownChecks[k] then
        umg.melt("missing isDown check for family: " .. tostring(k))
    end
end



function ControlManager:isFamilyLocked(family)
    assert(FAMILIES:has(family), "Invalid family")
    return self.familyLocks[family]
end


local function isInputDown(self, inputVal)
    local family, inpType = toPair(inputVal)
    if self:isFamilyLocked(family) then
        return false
    end
    local isDown = isDownChecks[family]
    return isDown(inpType)
end


local EMPTY = {}

local function getInputs(self, controlEnum)
    if not self.controlToInputs[controlEnum] then
        return EMPTY
    end
    return self.controlToInputs[controlEnum]
end

local function getControlEnums(self, inputVal)
    if not self.inputToControls[inputVal] then
        return EMPTY
    end
    return self.inputToControls[inputVal]
end


local function isControlDown(self, controlEnum)
    local inputs = getInputs(self, controlEnum)
    for _, inputVal in ipairs(inputs) do
        if isInputDown(self, inputVal) then
            return true
        end
    end
end



function ControlManager:isLockedForListener(controlEnum, listenerObject)
    assert(listenerObject, "?")
    if self.controlLocks[controlEnum] then
        return self.controlLocks[controlEnum] ~= listenerObject
    end
end


function ControlManager:isDownForListener(controlEnum, listenerObject)
    assert(listenerObject, "?")
    --[[
        checks whether
    ]]
    if self:isLockedForListener(controlEnum, listenerObject) then
        -- Control is being locked by another listener...
        return false -- therefore, locked!
    end
    return isControlDown(self, controlEnum)
end





local function press(self, controlEnum)
    self.onControlPressed(controlEnum)
end


local function anyOtherInputsPressed(self, controlEnum, ignoreInputVal)
    --[[
    checks if there are any other inputVals (other than `ignoreInputVal`)
    that are keeping controlEnum pressed.
    ]]
    local inputVals = getInputs(self, controlEnum)
    for _, inputVal in ipairs(inputVals) do
        if (inputVal ~= ignoreInputVal) and isInputDown(self, inputVal) then
            return true
        end
    end
    return false
end



local function tryPress(self, inputVal)
    local controlEnums = getControlEnums(self, inputVal)
    for _, controlEnum in ipairs(controlEnums) do
        if not anyOtherInputsPressed(self, controlEnum, inputVal) then
            press(self, controlEnum)
        end
    end
end


local function release(self, controlEnum)
    self.onControlReleased(controlEnum)
end


local function tryRelease(self, inputVal)
    local controlEnums = getControlEnums(self, inputVal)
    for _, controlEnum in ipairs(controlEnums) do
        if not anyOtherInputsPressed(self, controlEnum, inputVal) then
            release(self, controlEnum)
        end
    end
end




function ControlManager:mousepressed(_mx, _my, button, _istouch, _presses)
    local inputVal = fromPair(FAMILIES.mouse, button)
    tryPress(self, inputVal)
end


function ControlManager:mousereleased(_mx,_my, button)
    local inputVal = fromPair(FAMILIES.mouse, button)
    tryRelease(self, inputVal)
end


function ControlManager:keypressed(_key, scancode, _isrepeat)
    local inputVal = fromPair(FAMILIES.key, scancode)
    tryPress(self, inputVal)
end


function ControlManager:keyreleased(_key, scancode, _isrepeat)
    local inputVal = fromPair(FAMILIES.key, scancode)
    tryRelease(self, inputVal)
end


local function emitScroll(self, dir)
    local inputVal = fromPair(FAMILIES.scroll, dir)
    -- press, then release immediately
    -- (Scroll events are completely instantaneous)
    tryPress(self, inputVal)
    tryRelease(self, inputVal)
end


function ControlManager:wheelmoved(dx,dy)
    if dx > 0 then
        emitScroll(self, "right")
    elseif dx < 0 then
        emitScroll(self, "left")
    end

    if dy > 0 then
        emitScroll(self, "up")
    elseif dy < 0 then
        emitScroll(self, "down")
    end
end







function ControlManager:lockFamily(family)
    -- locks an entire input family
    self.familyLocks[family] = true
end


function ControlManager:lockControl(controlEnum, listenerObject)
    self.controlLocks[controlEnum] = listenerObject
end


function ControlManager:resetLocks()
    self.controlLocks = {}
    self.familyLocks = {}
end



return ControlManager

