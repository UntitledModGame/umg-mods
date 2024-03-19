

local sync = {}


sync.proxyEventToClient = require("shared.proxy")

sync.autoSyncComponent = require("shared.auto_sync_component")

local filterAPI = require("shared.filters")
sync.filters = filterAPI.filters
sync.defineFilter = filterAPI.defineFilter


local tickDelta = require("shared.tick_delta")
sync.getTickDelta = tickDelta.getTickDelta
sync.getTimeOfLastTick = tickDelta.getTimeOfLastTick


local control = require("shared.control")

sync.isControlledBy = control.isControlledBy
sync.getController = control.getController

if client then
    -- only available clientside
    sync.isClientControlling = control.isClientControlling
end



if server then
    -- only available serverside.
    sync.syncComponent = require("shared.manual_sync_component")
end


sync.newDualFunction = require("shared.dual")



umg.expose("sync", sync)
