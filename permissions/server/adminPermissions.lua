

local permissions = {}



local DEFAULT_ADMIN_LEVEL = 0


local ADMIN_LEVELS = {--[[
    [clientId] -> adminLevel
]]}

ADMIN_LEVELS[server.getHostClient()] = math.huge


function permissions.getAdminLevel(clientId)
    return ADMIN_LEVELS[clientId] or DEFAULT_ADMIN_LEVEL
end


local setAdminLevelTc = typecheck.assert("string", "number")
function permissions.setAdminLevel(clientId, level)
    setAdminLevelTc(clientId, level)
    ADMIN_LEVELS[clientId] = level
end



return permissions

