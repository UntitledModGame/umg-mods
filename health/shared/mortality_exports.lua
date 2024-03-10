



local health = {}

if server then
    -- server-side only API
    health.server = {}
end



local kill = require("shared.kill")
local damage = require("shared.damage")




if server then
-- server-side only API
health.server = {}

function health.server.kill(ent)
    -- only callable by server
    kill(ent)
end

function health.server.damage(ent, dmg)
    damage(ent, dmg)
end

end



umg.expose("health", health)
