
---Availability: Client and Server
---@class sync.mod
local sync = {}


local proxyEventToClient = require("shared.proxy")

---Availability: Client and Server
---@param eventName string
function sync.proxyEventToClient(eventName)
    return proxyEventToClient(eventName)
end

---@class sync.AutoSyncOptions
---@field public type string
---@field public syncWhenNil? boolean
---@field public lerp? boolean
---@field public noDeltaCompression? boolean
---@field public numberSyncThreshold? integer
---@field public requiredComponents? string[]
---@field public bidirectional? {shouldAcceptServerside:function,shouldForceSyncClientside:function}

local autoSyncComponent = require("shared.auto_sync_component")

---Availability: Client and Server
---@param compName string
---@param options sync.AutoSyncOptions
function sync.autoSyncComponent(compName, options)
    return autoSyncComponent(compName, options)
end

local tickDelta = require("shared.tick_delta")
sync.getTickDelta = tickDelta.getTickDelta
sync.getTimeOfLastTick = tickDelta.getTimeOfLastTick


local control = require("shared.control")

sync.isControlledBy = control.isControlledBy

if client then
    ---Availability: **Client**
    ---@param ent Entity
    ---@return boolean
    function sync.isClientControlling(ent)
        return not not control.isClientControlling(ent)
    end
end



if server then
    local syncComponent = require("shared.manual_sync_component")

    ---Availability: **Server**
    ---@param ent Entity
    ---@param compName string
    function sync.syncComponent(ent, compName)
        return syncComponent(ent, compName)
    end
end




if false then
    _G.sync = sync
end
umg.expose("sync", sync)
return sync
