

local ControlManager = objects.Class("input:ControlManager")



local VALID_INPUT_FAMILIES = objects.Enum({
    -- list of valid input families:
    "mouse",
    "key",
    "scroll",
    --[[
        in future: joystick stuff:

        axis
            axis:left
            axis:up
            axis:down
            axis:right
        gamepad
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


local VALID_MOUSE_BUTTONS = {
    "1", "2", "3", "4", "5"
}
local function checkMouseButton(button)
    return VALID_MOUSE_BUTTONS[button]
end


local VALID_SCROLL_DIRECTIONS = {
    "left", "up", "down", "right"
}
local function checkScroll(scrollDir)
    return VALID_SCROLL_DIRECTIONS[scrollDir]
end





local function toPair(s)
    -- converts an inputKey (family:input)
    -- To a pair:  family, input
    local i = s:find("%:")
    return s:sub(1,i-1), s:sub(i+1)
end


local function fromPair(family, input)
    -- converts a pair to a `family:input`
    return family .. ":" .. input
end


local function assertInputVal(bool, inputVal)
    if not bool then
        error("Invalid input val: " .. tostring(inputVal))
    end
end

local function assertValidInput(inputVal)
    local family, inp = toPair(inputVal)

    if family == VALID_INPUT_FAMILIES.scroll then
        assertInputVal(checkScroll(inp), inputVal)
    elseif family == VALID_INPUT_FAMILIES.key then
        assertInputVal(checkKey(inp), inputVal)
    elseif family == VALID_INPUT_FAMILIES.mouse then
        assertInputVal(checkMouseButton(inp), inputVal)
    else
        error("Invalid input family: " .. tostring(inputVal))
    end
end




function ControlManager:init()
    self.controlToInputs = {--[[
        [controlEnum] -> Set{
            "key:a", "mouse:1", ...
        }
    ]]}

    self.inputToControls = {--[[
        [family:input] -> Set{
            controlEnum1, controlEnum2, ...
        }


        [family] -> {
            [input] -> Set{
                controlEnum1, controlEnum2, ...
            }
        }

        Exmample: {
            ["key"] -> {
                ["a"] -> Set({...})
            },
            ["mouse"] -> { ... }
            ["scroll"] -> { ... }
        }
    ]]}

    self.familyLocks = {--[[
        [family] -> true or false

        Allows us to lock input families
    ]]}

    self.validControls = {--[[
        [controlEnum] -> true/false
    ]]}
end



local function clearControls(self)
    self.controlToInputs = {}
    self.inputToControls = {}
end




local defineNewControlTc = typecheck.assert("table", "string")

local function defineNewControl(self, controlEnum)
    defineNewControlTc(self, controlEnum)
    if self.validControls[controlEnum] then
        error("controlEnum was already defined: " .. controlEnum)
    end
    self.validControls[controlEnum] = true
    self.controlToInputs[controlEnum] = objects.Set()
end


function ControlManager:defineControls(controls)
    for _, cEnum in ipairs(controls) do
        defineNewControl(cEnum)
    end
end






local function setControl(self, controlEnum, inputValList)
    self.controlToInputs[controlEnum] = objects.Set(inputValList)

    for _, inputVal in ipairs(inputValList) do
        assertValidInput(inputVal)
        local inpToCont = self.inputToControls[inputVal] or objects.Set() 
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
    for controlEnum, inputValList in ipairs(self.controlToInputs) do
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



function ControlManager:mousepressed(mx, my, button, istouch, presses)
end


function ControlManager:mousereleased(mx,my, button)
end


function ControlManager:keypressed(key, scancode, isrepeat)
end


function ControlManager:keyreleased(key, scancode, isrepeat)
end




local isDownChecks = {
    key = love.keyboard.isScancodeDown,
    mouse = function(x)
        return love.mouse.isDown(tonumber(x))
    end,
    wheel = function()
        -- not much we can do here.... 
        -- mousewheel movements are ephemeral and instantaneous
        return false
    end
}

for k,v in pairs(VALID_INPUT_FAMILIES) do
    assert(isDownChecks[k], "missing isDown check for family???")
end



local function isFamilyLocked(self, family)
    return self.familyLocks[family]
end


local function isInputDown(self, family, inpType)
    if isFamilyLocked(self, family) then
        return false
    end
    local isDown = isDownChecks[family]
    return isDown(inpType)
end


function ControlManager:isDown(controlEnum)
    local inputs = self.controlToInputs[controlEnum]
    for _, inputPair in ipairs(inputs) do
        local family, inpType = toPair(inputPair)
        if isInputDown(self, family, inpType) then
            return true
        end
    end
end



function ControlManager:lockFamily(family)
    self.familyLocks[family] = true
end


function ControlManager:resetLocks()
    self.familyLocks = {}
end



return ControlManager

