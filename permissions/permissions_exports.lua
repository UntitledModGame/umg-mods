

local permissions = {}


if server then

for k,v in pairs(require("server.adminPermissions")) do
    permissions[k] = v
end

end



for k,v in pairs(require("shared.entityPermissions")) do
    permissions[k] = v
end



umg.expose("permissions", permissions)

