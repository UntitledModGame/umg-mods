---@meta

sync = {}

---@param eventName string
function sync.proxyEventToClient(eventName)
end

---@class sync.AutoSyncOptions
---@field public type string
---@field public syncWhenNil? boolean
---@field public lerp? boolean
---@field public noDeltaCompression? boolean
---@field public numberSyncThreshold? integer
---@field public requiredComponents? string[]
---@field public bidirectional? {shouldAcceptServerside:function,shouldForceSyncClientside:function}

---@param compName string
---@param options sync.AutoSyncOptions
function sync.autoSyncComponent(compName, options)
end

---@param ent Entity
---@param compName string
function sync.syncComponent(ent, compName)
end

return sync
