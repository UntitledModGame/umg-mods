


local ER1 = "expected ppos"

typecheck.addType("ppos", function(x)
    if type(x) ~= "table" then
        return false, ER1
    end
    return x.plot and x.slot, ER1
end)


