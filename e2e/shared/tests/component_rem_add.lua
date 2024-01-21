

local appleGroup = umg.group("apple")
local allGroup = umg.group()



local function addComp(self)
    local e
    if server then
        e = server.entities.empty()
    end

    self:tick(4)

    if server then
        e.foo = 123
    end

    self:tick(4)

    self:assert(#allGroup == 1, "addComp: allGroup size not 1?")
    for _, ent in ipairs(allGroup) do
        self:assert(ent.foo == 123, "addComp: " .. tostring(ent))
    end
end


local function addCompFalse(self)
    local e
    if server then
        e = server.entities.empty()
    end

    self:tick(4)

    if server then
        e.foo = false
    end

    self:tick(4)

    self:assert(#allGroup == 1, "addCompFalse: allGroup size not 1?")
    for _, ent in ipairs(allGroup) do
        self:assert(ent.foo == false, "addCompFalse: " .. tostring(ent))
    end
end



local function removeComp(self)
    local N = 10

    if server then
        for _=1, N do
            local e = server.entities.empty()
            e.apple = "foo"
        end
    end

    self:assert(#appleGroup == 0, "appleGroup size not 0")
    self:tick(4)
    self:assert(#appleGroup == N, "appleGroup size not N")

    if server then
        for _, e in ipairs(allGroup) do
            e:removeComponent("apple")
        end
    end

    self:tick(4)
    self:assert(#appleGroup == 0, "appleGroup size not 0 (2nd time)")
end


local function addThenRemoveInstant(self)
    local N = 10

    if server then
        for _=1, N do
            local e = server.entities.empty()
            e.apple = "foo"
            e:removeComponent("apple")
        end
    end

    self:tick(3)
    self:assert(#appleGroup == 0, "appleGroup size not 0 (3rd time)")
end



zenith.test(function(self)
    self:clear()
    addComp(self)

    self:clear()
    removeComp(self)

    self:clear()
    addCompFalse(self)

    self:clear()
    addThenRemoveInstant(self)
end)


