--[[

Context:

There is one "Context" object when a lootplot test suite is running.
(The "Context" object belongs to the worldEnt)

----------------------------------

For testing purpose, points and money are shared

Objective:
Ensure the test suite runs successful.
]]

---@class lootplot.test.TestContext: objects.Class
local TestContext = objects.Class("lootplot.test:TestContext")

umg.definePacket("lootplot.test:syncContextValue", {
    typelist = {"entity", "string", "number"}
})
local VALUES = {
    money = true,
    points = true,
    combo = true
}

function TestContext:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    self.combo = 0
    self.money = 0
    self.points = 0
end


function TestContext:sync()
    -- syncs everything:
    for field, _ in pairs(VALUES) do
        self:syncValue(field)
    end
end

function TestContext:tick()
    local plot = self:getPlot()
    plot:tick()
end

---@return lootplot.Plot
function TestContext:getPlot()
    return self.ownerEnt.plot
end

function TestContext:syncValue(key)
    assert(server, "This function can only be called on server-side.")
    if not VALUES[key] then
        error("Invalid key: " .. key)
    end
    server.broadcast("lootplot.test:syncContextValue", self.ownerEnt, key, self[key])
end

if client then
    client.on("lootplot.test:syncContextValue", function(ent, field, val)
        ent.lootplotContext[field] = val
    end)
end

function TestContext:isPipelineEmpty()
    return self.ownerEnt.plot.pipeline:isEmpty()
end

if server then

function TestContext:setPoints(ent, x)
    self.points = x
    self:syncValue("points")
end

function TestContext:setMoney(ent, x)
    self.money = x
    self:syncValue("money")
end

function TestContext:setCombo(ent, x)
    self.combo = x
    self:syncValue("combo")
end

end

function TestContext:getPoints(ent)
    return self.points
end

function TestContext:getMoney(ent)
    return self.money
end

function TestContext:getCombo(ent)
    return self.combo
end

return TestContext
