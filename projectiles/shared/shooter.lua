


local VALID_OPTIONS = {
    -- if `ent.shooter` has any of these values,
    -- then it is regarded as a valid shooter config:
    "spawnProjectile",
    "projectileType",
    "count"
}


local function isValid(shComp)
    for _, opt in ipairs(VALID_OPTIONS) do
        if shComp[opt] then
            return true
        end
    end
    return false
end


local shoot
if server then
    shoot = require("server.shooter")
elseif client then
    function shoot(holderEnt, useEnt, shooter)
        --[[
            TODO: 
            Here, on clientside, we should add options for more interesting stuff.
            such as playing sfx, particles, etc.
        ]]
    end
end




local function callShoot(holderEnt, useEnt, shooter)
    umg.call("projectiles:useShooter", holderEnt, useEnt, shooter)
    shoot(holderEnt, useEnt, shooter)
end


local function tryShoot(holderEnt, useEnt)
    local shooter = useEnt.shooter
    if isValid(shooter) then
        callShoot(holderEnt, useEnt, shooter)
    end
end




umg.on("execution:use", function(holderEnt, useEnt) 
    local targX, targY = holderEnt.lookX, holderEnt.lookY
    if (not targX) or (not targY) then
        return
    end
    if (not holderEnt.x) or (not holderEnt.y) then
        return
    end

    if useEnt.shooter then
        local shooter = useEnt.shooter
        assert(type(shooter) == "table", "ent.shooter needs to be a table")
        tryShoot(holderEnt, useEnt)
    end
end)




