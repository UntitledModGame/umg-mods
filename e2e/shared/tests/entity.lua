
local entGroup = umg.group("mycomp")


local NUM = 3

---@param self zenith.TestContext
local function beforeEach(self)
    zenith.clear(self)
    self:tick(2)
    if server then
        local reffed = server.entities.empty()
        reffed.isRef = true

        for _=1,NUM do
            local e = server.entities.empty()
            e.mycomp = "hello there"
            e.ref = reffed
        end
    end
    self:tick(2)
end

---@param self zenith.TestContext
local function testShallowClone(self)
    beforeEach(self)

    local sze = entGroup:size()

    if server then
        for _, ent in ipairs(entGroup)do
            ent:shallowClone()
        end
    end

    self:tick(4)

    -- expect the entGroup size to have doubled
    self:assert(sze * 2, entGroup:size().." shallowClone group size")

    local reffed = entGroup[1].ref
    self:assert(reffed.isRef, "reffed was not valid somehow")
    for _, ent in ipairs(entGroup)do
        self:assert(ent.ref == reffed, "entity didn't reference reffed")
    end
end


---@param self zenith.TestContext
local function testDeepClone(self)
    beforeEach(self)

    local sze = #entGroup

    if server then
        for _, ent in ipairs(entGroup)do
            -- clone twice, and then delete the original
            ent:clone()
            ent:clone()
            ent:delete()
        end
    end

    self:tick()
    self:tick()

    -- expect the entGroup size to have doubled
    self:assertEquals(sze * 2, entGroup:size(), "clone group size")

    local seenDummys = {}
    for _, ent in ipairs(entGroup)do
        local reffed = ent.ref
        if seenDummys[reffed] then
            self:fail("reffed wasn't deepcopied!")
        end
        self:assert(umg.exists(reffed) and reffed.isRef, "clone: entity didn't reference reffed")
        seenDummys[reffed] = ent
    end
end




---@param self zenith.TestContext
local function testDeepDelete(self)
    beforeEach(self)

    local e1, e2
    if server then
        e1 = server.entities.empty()
        e2 = server.entities.empty()
        e1.foo = e2
    end

    self:tick()

    if server then
        --[[
        When we delete `e1`, it should ALSO
        delete all the entities that it references.
        (So e2 should be deleted)
        ]]
        e1:delete()
    end

    self:tick(2)

    self:assert(not umg.exists(e2), "???")
end


zenith.test("e2e:entity", function(self)
    testShallowClone(self)

    testDeepClone(self)

    testDeepDelete(self)
end)

