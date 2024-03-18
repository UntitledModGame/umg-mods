

local ER = "expected ppos"

local function checkPpos(x)
    if type(x) ~= "table" then
        return false, ER
    end
    return x.slot and x.plot, ER
end

typecheck.addType("ppos", checkPpos)




local ER2 = "expected pass"

local function checkPass(x)
    if not checkPpos(x) then
        return false, ER2
    end
    return umg.exists(x.entity), ER2
end

typecheck.addType("pass", checkPass)

