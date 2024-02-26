

local permissions = {}


if server then

local adminPermissions = require("server.adminPermissions")

permissions.getAdminLevel = adminPermissions.getAdminLevel
permissions.setAdminLevel = adminPermissions.setAdminLevel

end





local entityPermissions = require("shared.entityPermissions")

permissions.entityHasPermission = entityPermissions



umg.expose("permissions", permissions)

