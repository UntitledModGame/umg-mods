

local execution = {}


function execution.execute(executableEnt)
    -- force-executes an entity
end

function execution.canExecute(executableEnt)
    if not executableEnt.executable then
        return
    end
    if umg.ask("execution:")
end



function execution.use(usableEnt, userEnt)

end

function execution.canUse(usableEnt, userEnt)

end








return execution

