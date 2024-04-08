
--[[

Basic class object.

Usage:

local MyClass = Class("class_name_foo") 
-- class_name_foo is used for serialization purposes.


function MyClass:init(a,b,c)
    print("obj instantiated with args: ", a,b,c)
end


function MyClass:method(arg)
    print("Hello, I am a method.")
    print(self, arg)
end



]]

local name_to_class = {
--[[
    [class_name] = class
]]
}


local function newObj(class, ...)
    local obj = {}
    setmetatable(obj, class)
    if type(obj.init) == "function" then
        obj:init(...)
    end
    return obj
end


local default_class_mt = {__call = newObj}



local function assertStaticCall(self, class)
    if self~=class then
        umg.melt("Cannot be called on instances!", 2)
    end
end



local function Class(name)
    if type(name) ~= "string" then
        umg.melt("class(name) expects a string as first argument")
    end
    if name_to_class[name] then
        umg.melt("duplicate class name: " .. name)
    end

    local class = {}
    class.__index = class
    class.___implementors = {--[[
        -- set of Classes that this class implements
        [Class] -> true
    ]]}
    class.___implementors[class] = true

    function class:isInstance(x)
        assertStaticCall(self, class)
        if type(x) ~= "table" then
            return false
        end
        local cls = getmetatable(x)
        return class.___implementors[cls]
    end

    local tableTc = typecheck.assert("table", "table")
    function class:implement(otherClass)
        tableTc(self, otherClass)
        assertStaticCall(self, class)
        self.___implementors[otherClass] = true
        for k,v in pairs(otherClass) do
            if not self[k] then
                self[k] = v
            end
        end
        return self
    end

    setmetatable(class, default_class_mt)

    umg.register(class, name)
    return class
end



return Class

