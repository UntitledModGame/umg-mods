

--[[

Sparse-Set implementation.


Supports O(1) addition and removal.
Also supports iteration.

Order is not consistent, and will change quite dynamically.


]]

-- Need to make sure this is loaded; it may not be loaded yet
local Class = require("shared.Class")


local Set = Class("objects:Set")


function Set:init(initial)
    self.pointers = {}
    self.len     = 0
    if initial then
        for i=1, #initial do
            self:add(initial[i])
        end
    end
end


--- Clears the sSet completely.
function Set:clear()
    local obj
    local ptrs = self.pointers
    for i=1, self.len do
        obj = self[i]
        ptrs[obj] = nil
        self[i] = nil    
    end

    self.len = 0
    return self
end



-- Adds an object to the Set
function Set:add(obj)
   if self:has(obj) then
      return self
   end

   local sze = self.len + 1

   self[sze] = obj
   self.pointers[obj] = sze
   self.len          = sze

   return self
end



function Set:intersection(other)
    local newSet = Set()
    for _, v in ipairs(self) do
        if other:has(v) then
            newSet:add(v)
        end
    end
    return newSet
end


function Set:union(other)
    local newSet = Set()
    for _, v in ipairs(other) do
        newSet:add(v)
    end
    for _,v in ipairs(self) do
        newSet:add(v)
    end
    return newSet
end




local funcTc = typecheck.assert("table", "function")

function Set:filter(func)
    funcTc(self, func)
    local newSet = Set()
    for i=1, self.len do
        local item = self[i]
        if func(item) then
            newSet:add(item)
        end
    end
    return newSet
end




-- Removes an object from the Set.
-- If the object isn't in the Set, returns nil.
function Set:remove(obj, index)
    if not obj then
        return nil
    end
    if not self.pointers[obj] then
        return nil
    end

    index = index or self.pointers[obj]
    local sze  = self.len

    if index == sze then
        self[sze] = nil
    else
        local other = self[sze]

        self[index]  = other
        self.pointers[other] = index

        self[sze] = nil
    end

    self.pointers[obj] = nil
    self.len = sze - 1

    return self
end


function Set:length()
    return self.len
end

Set.size = Set.length -- alias



-- returns true if the Set contains `obj`, false otherwise.
function Set:has(obj)
   return self.pointers[obj] and true
end

Set.contains = Set.has -- alias



return Set

