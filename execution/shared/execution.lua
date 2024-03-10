

local execution = {}


if server then
function execution.execute(executableEnt)
    -- force-executes an entity
    umg.call("execution:executeEntity", executableEnt)
end
end

function execution.canExecute(executableEnt)
    if executableEnt.canExecute then
        if not executableEnt:canExecute() then
            return false
        end
    end
    if umg.ask("execution:isExecutionBlocked", executableEnt) then
        return false
    end
    return true
end



if server then
function execution.useEntity(usableEnt, userEnt)
    -- force-uses an entity
    umg.call("execution:useEntity", usableEnt, userEnt)
end
end

function execution.canUse(usableEnt, userEnt)
    if not execution.canExecute(usableEnt) then
        return false
    end
    if usableEnt.canUse then
        if not usableEnt:canUse(userEnt) then
            return false
        end
    end
    if umg.ask("execution:isUsageBlocked", usableEnt, userEnt) then
        return false
    end
    return true
end



sync.proxyEventToClient("execution:useEntity")
sync.proxyEventToClient("execution:executeEntity")





return execution

