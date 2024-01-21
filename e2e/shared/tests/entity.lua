
local entGroup = umg.group("mycomp")


local NUM = 3


local function beforeEach(self)
    self:clear()
    self:tick(2)
    if server then
        local dummy = server.entities.empty()
        dummy.isDummy = true

        for _=1,NUM do
            local e = server.entities.empty()
            e.mycomp = "hello there"
            e.ref = dummy
        end
    end
    self:tick(2)
end


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
    self:assert(sze * 2, entGroup:size(), "shallowClone group size")

    local dummy = entGroup[1].ref
    self:assert(dummy.isDummy, "dummy was not valid somehow")
    for _, ent in ipairs(entGroup)do
        self:assert(ent.ref == dummy, "entity didn't reference dummy")
    end
end



local function testDeepClone(self)
    beforeEach(self)

    local sze = #entGroup

    if server then
        for _, ent in ipairs(entGroup)do
            -- clone twice, and then delete the original
            ent:deepClone()
            ent:deepClone()
            ent:delete()
        end
    end

    self:tick()
    self:tick()

    -- expect the entGroup size to have doubled
    self:assertEquals(sze * 2, entGroup:size(), "deepClone group size")

    local seenDummys = {}
    for _, ent in ipairs(entGroup)do
        local dummy = ent.ref
        if seenDummys[dummy] then
            print(seenDummys[dummy])
            print(ent)
            self:fail("dummy wasn't deepcopied!")
        end
        self:assert(umg.exists(dummy) and dummy.isDummy, "deepClone: entity didn't reference dummy")
        seenDummys[dummy] = ent
    end
end




local function testDeepDelete(self)
    beforeEach(self)

    local empty2
    if server then
        empty2 = server.entities.empty()
        empty2.arr = {}

        for _, ent in ipairs(entGroup) do
            table.insert(empty2.arr, ent)
        end
    end

    self:tick()

    if server then
        empty2:deepDelete()
    end

    self:tick(2)

    self:assert(entGroup:size() == 0, "Nested entities not deleted")
end



zenith.test(function(self)
    testShallowClone(self)

    testDeepClone(self)
    
    testDeepDelete(self)
end)

