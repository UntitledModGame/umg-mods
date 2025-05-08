---@class lootplot.singleplayer.RunManager
local runManager = {}



umg.definePacket("lootplot.singleplayer:runData", {typelist = {"boolean", "string"}})
umg.definePacket("lootplot.singleplayer:startRun", {typelist = {"string"}})
umg.definePacket("lootplot.singleplayer:continueRun", {typelist = {}})


local RUN_FILENAME = "run.bin"


local function loadRunServer()
    local save = server.getSaveFilesystem()

    if save:exists(RUN_FILENAME) then
        ---@type lootplot.singleplayer.RunSerialized
        local runSerialized, msg = umg.deserialize((assert(save:read(RUN_FILENAME))))
        if not runSerialized then
            umg.log.error("Cannot serialize run: "..msg)
        else
            assert(runSerialized)
        end
        return runSerialized
    end

    return nil
end

local function queryRunServer()
    local runSerialized = loadRunServer()

    if runSerialized then
        return runSerialized.runMeta
    end

    return nil
end

---@param run lootplot.singleplayer.Run
local function serializeRun(run)
    ---@class lootplot.singleplayer.RunSerialized
    local data = {
        runMeta = run:getMetadata(),
        runData = run:serialize(),
        rngState = lp.SEED:serializeToTable()
    }
    return umg.serialize(data)
end

---@param run lootplot.singleplayer.Run
local function saveRunServer(run)
    local save = server.getSaveFilesystem()
    local runSerialized = nil

    if run:canSerialize() then
        umg.log.debug("Current run is serializable. Serializing run...")
        runSerialized = serializeRun(run)
    end

    if runSerialized then
        save:write(RUN_FILENAME, runSerialized)
    else
        umg.log.debug("Current run is not serializable. Discarding run...")
    end
end



if server then

local startRunService = require("server.start_run_service")

server.on("lootplot.singleplayer:startRun", function(clientId, runOptionsString)
    if server.getHostClient() == clientId then
        local runOptions = umg.deserialize(runOptionsString)
        startRunService.startGame(
            lp.singleplayer.PLAYER_TEAM,
            runOptions.starterItem,
            runOptions.difficulty,
            runOptions.worldgenItem,
            runOptions.background
        )
        lp.setPlayerTeam(clientId, lp.singleplayer.PLAYER_TEAM)
    end
end)

server.on("lootplot.singleplayer:continueRun", function(clientId)
    if server.getHostClient() == clientId then
        local runSerialized = assert(loadRunServer())
        startRunService.continueGame(runSerialized.runData, runSerialized.rngState)
        lp.setPlayerTeam(clientId, lp.singleplayer.PLAYER_TEAM)
    end
end)


umg.on("@playerJoin", function(clientId)
    local runData = ""
    local isHost = server.getHostClient() == clientId
    if isHost then
        local info = queryRunServer()
        if info then
            runData = umg.serialize(info)
        end
    end
    server.unicast(clientId, "lootplot.singleplayer:runData", isHost, runData)
end)


function runManager.saveRun()
    local run = lp.singleplayer.getRun()

    if run then
        saveRunServer(run)
        return true
    end

    return false
end

function runManager.deleteRun()
    local save = server.getSaveFilesystem()
    save:remove(RUN_FILENAME)
end





local function endSave()
    runManager.deleteRun()
    local run = lp.singleplayer.getRun()
    if run then
        run.runHasEnded = true
    end
end

umg.on("lootplot:loseGame", endSave)
umg.on("lootplot:winGame", endSave)



-- Whether or not we autosave.
local AUTOSAVE = true

if AUTOSAVE then
    local dirty = true

    umg.on("@tick", function(dt)
        local run = lp.singleplayer.getRun()
        if not run then return end

        if (run.runHasEnded) then return end

        if run:getPlot():isPipelineRunning() then
            dirty = true
        else -- pipeline is empty- therefore, it is safe to save.
            if dirty then
                runManager.saveRun()
                dirty = false
            end
        end
    end)

end


end -- if server


local runInfoArrived = false
local runInfo = nil


if client then

client.on("lootplot.singleplayer:runData", function(isHost, runmeta)
    -- TODO: Keep the isHost, in case if we want to support multiplayer
    runInfoArrived = true

    if #runmeta > 0 then
        runInfo = umg.deserialize(runmeta)
    end
end)

end -- if client

function runManager.hasReceivedInfo()
    -- Server always have run info, but client may not.
    return not not (runInfoArrived or server)
end

function runManager.getSavedRun()
    if server then
        return queryRunServer()
    else
        return runInfo
    end
end

function runManager.sendContinueRunPacket()
    client.send("lootplot.singleplayer:continueRun")
end


local newRunOptionsTc = typecheck.assert({
    starterItem = "string",
    seed = "string"
})
---@param options {starterItem:string,seed:string,background:string?,difficulty:number}
function runManager.sendStartRunPacket(options)
    newRunOptionsTc(options)
    client.send("lootplot.singleplayer:startRun", umg.serialize(options))
end

return runManager
