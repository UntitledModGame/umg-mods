---@class lootplot.main.RunManager
local runManager = {}

umg.definePacket("lootplot.main:runData", {typelist = {"boolean", "string"}})
umg.definePacket("lootplot.main:startRun", {typelist = {"string"}})
umg.definePacket("lootplot.main:continueRun", {typelist = {}})

---@class lootplot.main.RunMeta
---@field public playtime integer
---@field public level integer
---@field public perk string fully qualified name of the perk item name
---@field public seed integer

---@return lootplot.main.RunMeta|nil
local function queryRunServer()
    local save = server.getSaveFilesystem()

    if save:exists("run.bin") then
        local runmeta = json.decode(assert(save:read("run_meta.json")))
        return runmeta
    end

    return nil
    -- return {
    --     playtime = 1234,
    --     level = 4,
    --     perk = "lootplot.s0.starting_items:one_ball",
    --     seed = 1234
    -- }
end



if server then

local startRunService = require("server.start_run_service")

server.on("lootplot.main:startRun", function(clientId, runOptionsString)
    if server.getHostClient() == clientId then
        local runOptions = umg.deserialize(runOptionsString)
        startRunService.startGame(clientId, runOptions.starterItem)
    end
end)

server.on("lootplot.main:continueRun", function(clientId, continue, seed)
    if server.getHostClient() == clientId then
        -- umg.log.error("NYI.")
        -- continueRun()
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
    server.unicast(clientId, "lootplot.main:runData", isHost, runData)
end)

umg.on("@quit", function()
    umg.log.warn("TODO: Save run")
end)

end -- if server


local runInfoArrived = false
local runInfo = nil


if client then

client.on("lootplot.main:runData", function(isHost, runmeta)
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

function runManager.continueRun()
    client.send("lootplot.main:continueRun")
end


local newRunOptionsTc = typecheck.assert({
    starterItem = "string",
    seed = "string"
})
---@param options {starterItem:string,seed:string}
function runManager.startRun(options)
    newRunOptionsTc(options)
    client.send("lootplot.main:startRun", umg.serialize(options))
end

return runManager
