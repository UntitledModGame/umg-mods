local function add(x, y)
    return x + y
end

zenith.test("e2e:buses", function(self)
    umg.defineEvent("e2e:event_bus_test")

    umg.defineQuestion("e2e:question_bus_test", add)

    umg.answer("e2e:question_bus_test", function(x)
        return x
    end)
    umg.answer("e2e:question_bus_test", function(x)
        return x * 2
    end)

    umg.on("e2e:event_bus_test", function(val)
        self:assert(val == 1, "Expected 1")
    end)

    self:assert(umg.ask("e2e:question_bus_test", 3) == (3*2 + 3), "Expected 9")
    umg.call("e2e:event_bus_test", 1)
end)
