local runManager = {}

umg.definePacket("lootplot.main:queryRun", {typelist = {}})
umg.definePacket("lootplot.main:queryRunResult", {typelist = {"boolean", "string"}})
umg.definePacket("lootplot.main:newRun", {typelist = {"string"}})
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
    --     perk = "lootplot.content.s0:one_ball",
    --     seed = 1234
    -- }
end

---@param seed string
local function newRunServer(seed)
    umg.log.warn("NYI: lootplot.main:newRun", seed)
end

local function continueRunServer()
    umg.log.warn("NYI: lootplot.main:continueRun")
end

if server then

server.on("lootplot.main:queryRun", function(clientId)
    local host = server.getHostClient() == clientId
    local runmeta
    if host then
        runmeta = queryRunServer()
    end

    server.unicast(clientId, "lootplot.main:queryRunResult", host, runmeta and umg.serialize(runmeta) or "")
end)

server.on("lootplot.main:newRun", function(clientId, seed)
    if server.getHostClient() == clientId then
        newRunServer(seed)
    end
end)

server.on("lootplot.main:continueRun", function(clientId)
    if server.getHostClient() == clientId then
        continueRunServer()
    end
end)

umg.on("@quit", function()
    umg.log.warn("TODO: Save run")
end)

end

local queryRunCallback

if client then

client.on("lootplot.main:queryRunResult", function(isHost, runmeta)
    local runmetaDeser
    if #runmeta > 0 then
        runmetaDeser = umg.deserialize(runmeta)
    end

    local cb = queryRunCallback
    queryRunCallback = nil
    if cb then
        cb(isHost, runmetaDeser)
    end
end)

end

---@param callback fun(host:boolean,run:lootplot.main.RunMeta|nil)
function runManager.queryRun(callback)
    if server then
        callback(true, queryRunServer())
    else
        assert(not queryRunCallback, "only one runManager.queryRun can be run at a time")
        queryRunCallback = callback
        client.send("lootplot.main:queryRun")
    end
end

---@param seed string?
function runManager.newRun(seed)
    seed = seed or ""
    if server then
        newRunServer(seed)
    else
        client.send("lootplot.main:newRun", seed)
    end
end

function runManager.continueRun()
    if server then
        continueRunServer()
    else
        client.send("lootplot.main:continueRun")
    end
end

return runManager
